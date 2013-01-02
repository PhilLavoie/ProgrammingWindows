module keyview1;

import std.stdio;
import std.string;
import std.conv;
import std.algorithm;
import std.string;
import std.utf;
import core.runtime;

import win32.windef;
import win32.winuser;
import win32.wingdi;
import win32.mmsystem;

nothrow @pure bool isChar( UINT message ) {
  return message == WM_CHAR || message == WM_SYSCHAR || message == WM_DEADCHAR || message == WM_SYSDEADCHAR;
}

extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  static int cxChar, cxCaps, cyChar; 
  static int cxClient, cyClient, cxClientMax, cyClientMax;
  static int cLinesMax, cLines;
  static MSG[] messages;
  static RECT rectScroll;
  
  int type;  
  HDC hdc;
  PAINTSTRUCT ps; 
  RECT rect;
  SCROLLINFO si;
  TEXTMETRIC tm;
  
  int x, y, verticalPos, horizontalPos, paintBegin, paintEnd;
  
  try {

    switch( message ) {
      case WM_CREATE:
      case WM_DISPLAYCHANGE:
        //Maximum size of client area.
        cxClientMax = GetSystemMetrics( SM_CXMAXIMIZED );
        cyClientMax = GetSystemMetrics( SM_CYMAXIMIZED );
        
        hdc = GetDC( hwnd );
        scope( exit ) ReleaseDC( hwnd, hdc );
        
        SelectObject( hdc, GetStockObject( SYSTEM_FIXED_FONT ) );
        GetTextMetrics( hdc, &tm );      
        cxChar = tm.tmAveCharWidth;
        cxCaps = ( tm.tmPitchAndFamily & 1 ? 3 : 2 ) * cxChar / 2;
        cyChar = tm.tmHeight + tm.tmExternalLeading;
        //Remove previous messages.
        if( messages ) {
          delete messages;
        }
        
        cLinesMax = cyClientMax / cyChar;
        cLines = 0;       
        //Allocate new ones.
        messages = new MSG[ cLinesMax ];
        //Fall through.
      case WM_SIZE:
        if( message == WM_SIZE ) {
          cxClient = LOWORD( lParam );
          cyClient = HIWORD( lParam );
        }
        //Scrolling rectangle.
        rectScroll.left = 0;
        rectScroll.right = cxClient;
        rectScroll.top = cyChar;
        rectScroll.bottom = cyChar * ( cyClient / cyChar );
        InvalidateRect( hwnd, null, true );
        return 0;
      case WM_KEYDOWN:
      case WM_KEYUP:
      case WM_CHAR:
      case WM_DEADCHAR:
      case WM_SYSKEYDOWN:
      case WM_SYSKEYUP:
      case WM_SYSCHAR:
      case WM_SYSDEADCHAR:
        //Rearrange storage array.
        for( int i = cLines - 1; 0 < i; --i ) {
          messages[ i ] = messages[ i - 1 ];
        }
        messages[ 0 ].hwnd = hwnd;
        messages[ 0 ].message = message;
        messages[ 0 ].wParam = wParam;
        messages[ 0 ].lParam = lParam;
        
        cLines = min( cLines + 1, cLinesMax );
        //Scroll up the display.
        ScrollWindow( hwnd, 0, -cyChar, &rectScroll, &rectScroll );        
        break;
      case WM_PAINT:
        hdc = BeginPaint( hwnd, &ps );
        scope( exit ) EndPaint( hwnd, &ps );
        
        SelectObject( hdc, GetStockObject( SYSTEM_FIXED_FONT ) );
        SetBkMode( hdc, TRANSPARENT );
        for( i = 0; i < min( cLines, cyClient / cyChar - 1 ); ++i ) {
          char[ 32 ] keyName;
          auto msg = messages[ i ];
          GetKeyNameTextA( msg.lParam, keyName.ptr, keyName.sizeof );
          string data;
          if( isChar( msg.message ) ) {
            data = 
              keyName ~ " " ~ msg.wParam ~ " " ~
              msg.
          } else {
          
          }
          TextOut( hdc, 0, ( cyClient / cyChar - 1 - i ) * cyChar, 
            data.toUTFz!( TCHAR * ), data.length * TCHAR.sizeof );
        }
        
        
        return 0;    
      case WM_DESTROY:
        PostQuitMessage( 0 );
        return 0;    
      default:
        return DefWindowProc( hwnd, message, wParam, lParam );
    }
    return DefWindowProc( hwnd, message, wParam, lParam );
  } catch( Throwable t ) {
    assert( false );
  }
  return DefWindowProc( hwnd, message, wParam, lParam );
}

void register( ref WNDCLASS wndClass ) {
  if ( !RegisterClass( &wndClass ) ) { 
    throw new Exception( "Unable to register class" );
  }
}


int mainImpl( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow ) {
  auto className = "My First M'ofocking Window".toUTFz!( TCHAR * );
  WNDCLASS wndClass;
  
  //Window class definition.
  wndClass.style = CS_HREDRAW | CS_VREDRAW;
  wndClass.lpfnWndProc = &WndProc;
  wndClass.cbClsExtra = 0;
  wndClass.cbWndExtra = 0;
  wndClass.hInstance  = hInstance;
  wndClass.hIcon = LoadIcon( null, IDI_EXCLAMATION );
  wndClass.hCursor = LoadCursor( null, IDC_CROSS );
  wndClass.hbrBackground = GetStockObject( WHITE_BRUSH );
  wndClass.lpszMenuName = null;
  wndClass.lpszClassName = className;
  //Register the class.
  wndClass.register();
  //Then create an instance.
  HWND hWnd;
  hWnd = CreateWindow(
    className,                        //Window class used.
    "SYSMETS4".toUTFz!( TCHAR * ),  //Window caption.
    WS_OVERLAPPEDWINDOW | WS_VSCROLL |WS_HSCROLL,                    //Window style.
    CW_USEDEFAULT,                    //Initial x position.
    CW_USEDEFAULT,                    //Initial y position.
    CW_USEDEFAULT,                    //Initial x size.
    CW_USEDEFAULT,                    //Initial y size.
    null,                             //Parent window handle.
    null,                             //Window menu handle.
    hInstance,                        //Program instance handle.
    null                              //Creation parameters.
  );                           

  ShowWindow( hWnd, SW_SHOWNORMAL );
  UpdateWindow( hWnd ); 

  MSG msg;
  while( true ) {
    if( PeekMessage( &msg, null, 0, 0, PM_REMOVE ) ) {
      if (msg.message == WM_QUIT) 
        break;
      
      TranslateMessage( &msg );
      DispatchMessage( &msg );
    } else {
      ;
    }
  }

  return msg.wParam; 
}

extern (Windows) int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
  int result;
  void exceptionHandler(Throwable e) { throw e; }

  try {
    Runtime.initialize(&exceptionHandler);
    result = mainImpl(hInstance, hPrevInstance, lpCmdLine, iCmdShow);
    Runtime.terminate(&exceptionHandler);
  } catch( Throwable o ) {
    MessageBox( null, o.toString().toUTFz!( TCHAR * ), "Error", MB_OK | MB_ICONEXCLAMATION );
    result = 0;
  }

  return result;
}



