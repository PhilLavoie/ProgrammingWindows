module randrect;

import std.stdio;
import std.string;
import std.conv;
import std.c.stdlib;


import core.runtime;

import win32.windef;
import win32.winuser;
import win32.wingdi;
import win32.mmsystem;

private int cxClient, cyClient;

nothrow void drawRectangle( HWND hwnd ) {
  RECT rect;
  if( !cxClient || !cyClient ) { return; }
  SetRect( 
    &rect, 
    rand() % cxClient, 
    rand() % cyClient, 
    rand() % cxClient, 
    rand() % cyClient 
  );
  HBRUSH hbrush;
  hbrush = CreateSolidBrush( 
    RGB( 
      cast( ubyte )( rand() % 256 ),
      cast( ubyte )( rand() % 256 ),
      cast( ubyte )( rand() % 256 )
    ) 
  );
  scope( exit ) DeleteObject( hbrush );
 
  HDC hdc;
  hdc = GetDC( hwnd );
  scope( exit ) ReleaseDC( hwnd, hdc );
  
  FillRect( hdc, &rect, hbrush ); 
}

extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  switch( message ) {
    case WM_SIZE:
      cxClient = LOWORD( lParam );
      cyClient = HIWORD (lParam);
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
      drawRectangle( hWnd );
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