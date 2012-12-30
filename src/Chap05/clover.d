module clover;

import std.stdio;
import std.string;
import std.conv;
import std.math;
import cmath = std.c.math;
import core.runtime;

import win32.windef;
import win32.winuser;
import win32.wingdi;
import win32.mmsystem;

const real TWOPI = ( 2 * PI );


extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  static HRGN hrgnClip;
  static int cxClient, cyClient;
  float angle, radius;
  HCURSOR hcursor;
  HDC hdc;
  HRGN hrgnTemp[ 6 ];
  PAINTSTRUCT ps;
  
  switch( message ) {
    case WM_SIZE:
      cxClient = LOWORD( lParam );
      cyClient = HIWORD( lParam );
      hcursor = SetCursor( LoadCursor( null, IDC_WAIT ) );
      ShowCursor( true );
      hrgnTemp[ 0 ] = CreateEllipticRgn( 0           , cyClient / 3, cxClient / 2    , 2 * cyClient / 3 );
      hrgnTemp[ 1 ] = CreateEllipticRgn( cxClient / 2, cyClient / 3, cxClient        , 2 * cyClient / 3 );
      hrgnTemp[ 2 ] = CreateEllipticRgn( cxClient / 3, 0           , 2 * cxClient / 3, cyClient / 2     );
      hrgnTemp[ 3 ] = CreateEllipticRgn( cxClient / 3, cyClient / 2, 2 * cxClient / 3, cyClient         );
      hrgnTemp[ 4 ] = CreateEllipticRgn( 0           , 0           , 1               , 1                );
      hrgnTemp[ 5 ] = CreateEllipticRgn( 0           , 0           , 1               , 1                );
      if( !hrgnClip ) {
        hrgnClip      = CreateEllipticRgn( 0           , 0           , 1               , 1                );
      }
      
      scope( exit ) {
        foreach( hrgn; hrgnTemp ) {
          DeleteObject( hrgn );
        }
      }
      
      CombineRgn( hrgnTemp[ 4 ], hrgnTemp[ 0 ], hrgnTemp[ 1 ], RGN_OR );
      CombineRgn( hrgnTemp[ 5 ], hrgnTemp[ 2 ], hrgnTemp[ 3 ], RGN_OR );
      CombineRgn( hrgnClip     , hrgnTemp[ 4 ], hrgnTemp[ 5 ], RGN_XOR );
           
      SetCursor( hcursor );    
      ShowCursor( false );
      return 0;
    case WM_PAINT:
      hdc = BeginPaint( hwnd, &ps );
      scope( exit ) EndPaint( hwnd, &ps );
      SetViewportOrgEx( hdc, cxClient / 2, cyClient / 2, null );
      SelectClipRgn( hdc, hrgnClip );
      radius = hypot( cxClient / 2.0, cyClient / 2.0 );
      for( angle = 0; angle < TWOPI; angle += TWOPI / 360 ) {
        MoveToEx( hdc, 0, 0, null );
        LineTo( 
          hdc, 
          cast( int )( radius  * cmath.cos( angle ) ), 
          cast( int )( radius * cmath.sin( angle ) )
        );
      }
      return 0;    
    case WM_DESTROY:
      DeleteObject( hrgnClip );
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