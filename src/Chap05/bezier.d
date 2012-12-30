module bezier;

import std.stdio;
import std.string;
import std.conv;


import core.runtime;

import win32.windef;
import win32.winuser;
import win32.wingdi;
import win32.mmsystem;

nothrow void drawBezier( HDC hdc, POINT[] points ) {
  PolyBezier( hdc, points.ptr, 4 );
  MoveToEx( hdc, points[ 0 ].x, points[ 0 ].y, null );
  LineTo( hdc, points[ 1 ].x, points[ 1 ].y );
  MoveToEx( hdc, points[ 2 ].x, points[ 2 ].y, null );
  LineTo( hdc, points[ 3 ].x, points[ 3 ].y );  
}

extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  static int cxClient, cyClient; //Current window size (width and height).
  static POINT[ 4 ] points;
  
  HDC hdc;
  PAINTSTRUCT ps; 
  
  switch( message ) {
    case WM_SIZE:
      cxClient = LOWORD( lParam );
      cyClient = HIWORD (lParam);
      points[ 0 ].x = cxClient / 4;
      points[ 0 ].y = cyClient / 2;
      
      points[ 1 ].x = cxClient / 2;
      points[ 1 ].y = cyClient / 4;
      
      points[ 2 ].x = cxClient / 2;
      points[ 2 ].y = cyClient * 3 / 4;
      
      points[ 3 ].x = cxClient * 3 / 4;
      points[ 3 ].y = cyClient / 2;      
      return 0;
    case WM_LBUTTONDOWN:
    case WM_RBUTTONDOWN:
    case WM_MOUSEMOVE:
      if( wParam & MK_LBUTTON || wParam & MK_RBUTTON ) {
        hdc = GetDC( hwnd );
        scope( exit ) ReleaseDC( hwnd, hdc );
        SelectObject( hdc, GetStockObject( WHITE_PEN ) );
        drawBezier( hdc, points[] );
        if( wParam & MK_LBUTTON ) {
          points[ 1 ].x = LOWORD( lParam );
          points[ 1 ].y = HIWORD( lParam );
        }
        if( wParam & MK_RBUTTON ) {
          points[ 2 ].x = LOWORD( lParam );
          points[ 2 ].y = HIWORD( lParam );
        }
        SelectObject( hdc, GetStockObject( BLACK_PEN ) );
        drawBezier( hdc, points[] );   
      }
      return 0;
    case WM_PAINT:
      InvalidateRect( hwnd, null, true );
      hdc = BeginPaint( hwnd, &ps );
      scope( exit ) EndPaint( hwnd, &ps );
      drawBezier( hdc, points[] );
      return 0;
    case WM_DESTROY:
      PostQuitMessage( 0 );
      return 0;
    default:
      return DefWindowProcA( hwnd, message, wParam, lParam );
  }
  assert( false );
}

void register( ref WNDCLASS wndClass ) {
  if ( !RegisterClassA( &wndClass ) ) { 
    throw new Exception( "Unable to register class" );
  }
}


int mainImpl( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow ) {
  auto className = toStringz( "My First M'ofocking Window" );
  WNDCLASS wndClass;
  
  //Window class definition.
  wndClass.style = CS_HREDRAW | CS_VREDRAW;
  wndClass.lpfnWndProc = &WndProc;
  wndClass.cbClsExtra = 0;
  wndClass.cbWndExtra = 0;
  wndClass.hInstance  = hInstance;
  wndClass.hIcon = LoadIconA( null, IDI_EXCLAMATION );
  wndClass.hCursor = LoadCursorA( null, IDC_CROSS );
  wndClass.hbrBackground = GetStockObject( WHITE_BRUSH );
  wndClass.lpszMenuName = null;
  wndClass.lpszClassName = className;
  //Register the class.
  wndClass.register();
  //Then create an instance.
  HWND hWnd;
  hWnd = CreateWindowA(
    className,                        //Window class used.
    "The goddamn program".toStringz,  //Window caption.
    WS_OVERLAPPEDWINDOW,                    //Window style.
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
  while( GetMessageA( &msg, null, 0, 0 ) ) {
    TranslateMessage( &msg );
    DispatchMessageA( &msg );
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
    MessageBoxA( null, o.toString().toStringz, "Error", MB_OK | MB_ICONEXCLAMATION );
    result = 0;
  }

  return result;
}