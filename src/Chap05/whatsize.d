module whatsize;

import std.stdio;
import std.string;
import std.conv;


import core.runtime;

import win32.windef;
import win32.winuser;
import win32.wingdi;
import win32.mmsystem;

nothrow 
void show( HWND hwnd, HDC hdc, int xText, int yText, int mapMode, string szMapMode ) {
  RECT rect;
  //Convert coordinates.
  SaveDC( hdc );
  SetMapMode( hdc, mapMode );
  GetClientRect( hwnd, &rect );
  DPtoLP( hdc, cast( PPOINT )&rect, 2 );
  RestoreDC( hdc, -1 );
  string modeValue;
  try {
    modeValue = 
      szMapMode ~ 
      ": left = " ~ to!string( rect.left ) ~
      ", right = " ~ to!string( rect.right ) ~
      ", top = " ~ to!string( rect.top ) ~
      ", bottom = " ~ to!string( rect.bottom );
  } catch( Throwable t ) { assert( false ); }
  TextOut( hdc, xText, yText, modeValue.toStringz, modeValue.length );
  
}

extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  static int cxClient, cyClient; //Current window size (width and height).
  static int cxChar, cyChar;
  HDC hdc;
  PAINTSTRUCT ps; 
  TEXTMETRIC tm;
  
  switch( message ) {
    case WM_CREATE:
      hdc = GetDC( hwnd );
      scope( exit ) ReleaseDC( hwnd, hdc );
      
      SelectObject( hdc, GetStockObject( SYSTEM_FIXED_FONT ) );
      GetTextMetrics( hdc, &tm );
      cxChar = tm.tmAveCharWidth;
      cyChar = tm.tmHeight + tm.tmExternalLeading;
      return 0;
    case WM_SIZE:
      cxClient = LOWORD( lParam );
      cyClient = HIWORD (lParam);
      return 0;
    case WM_PAINT:
      hdc = BeginPaint( hwnd, &ps );
      scope( exit ) EndPaint( hwnd, &ps );
      
      SelectObject( hdc, GetStockObject( SYSTEM_FIXED_FONT ) );
      SetMapMode( hdc, MM_ANISOTROPIC );
      SetWindowExtEx( hdc, 1, 1, null );
      SetViewportExtEx( hdc, cxChar, cyChar, null );
      show( hwnd, hdc, 1, 1, MM_TEXT, "Text (pixels)" );
      show( hwnd, hdc, 1, 2, MM_LOMETRIC, "Low metric (.1 mm)" );
      show( hwnd, hdc, 1, 3, MM_HIMETRIC, "High metric (.01 mm)" );
      show( hwnd, hdc, 1, 4, MM_LOENGLISH, "Low english (.01 in)" );
      show( hwnd, hdc, 1, 5, MM_HIENGLISH, "High english (.001 in)" );
      show( hwnd, hdc, 1, 6, MM_TWIPS, "Twips (1/1440 in)" );
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
    "What Size?".toStringz,  //Window caption.
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
  while( true ) {
    if( PeekMessage( &msg, null, 0, 0, PM_REMOVE ) ) {
      if (msg.message == WM_QUIT) 
        break;
      
      TranslateMessage( &msg );
      DispatchMessage( &msg );
    } else {
      //Do something while waiting for messages.
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
    MessageBoxA( null, o.toString().toStringz, "Error", MB_OK | MB_ICONEXCLAMATION );
    result = 0;
  }

  return result;
}