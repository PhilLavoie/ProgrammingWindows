import std.stdio;
import std.string;
import std.conv;
import core.runtime;

import std.c.windows.windows;

//Graphics.
pragma( lib, "gdi32.lib" );
//Multimedia.
pragma( lib, "winmm.lib" );

void register( ref WNDCLASS wndClass ) {
  if ( !RegisterClassA( &wndClass ) ) { 
    throw new Exception( "Unable to register class" );
  }
}

extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  HDC hdc;
  PAINTSTRUCT ps; 
  RECT rect;

  switch( message ) {
    case WM_CREATE:
      PlaySoundA( "boom.wav".toStringz, null, SND_FILENAME | SND_ASYNC );
      return 0;
    case WM_LBUTTONUP:
    case WM_PAINT:
      InvalidateRect( hwnd, null, true );
      hdc = BeginPaint( hwnd, &ps );
      GetClientRect( hwnd, &rect ); 
      DrawTextA( hdc, "Hello, Windows 98!".toStringz, -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER );
      EndPaint( hwnd, &ps ) ;
      return 0;
    case WM_DESTROY:
      PostQuitMessage( 0 );
      return 0;
    case WM_LBUTTONDOWN:
      InvalidateRect( hwnd, null, true );
      hdc = BeginPaint( hwnd, &ps );
      GetClientRect( hwnd, &rect );
      DrawTextA( hdc, "WOOOOOOOOOOOOOOOOOOOOOT".toStringz, -1, &rect, DT_SINGLELINE | DT_CENTER | DT_VCENTER );
      EndPaint( hwnd, &ps );
      return 0;      
    default:
      break;
  }
  return DefWindowProcA( hwnd, message, wParam, lParam );
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
  wndClass.hbrBackground = GetStockObject( DKGRAY_BRUSH );
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
 

  ShowWindow( hWnd, SW_SHOWMAXIMIZED );
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



