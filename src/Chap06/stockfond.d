module stockfont;

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
import win32.winnt;

TCHAR * TEXT( string text ) {
  return text.toUTFz!( TCHAR * );
}

/**
  */
struct StockFont {
  size_t id;
  TCHAR * name;
  this( int index, string name ) {
    this.id = index;
    this.name = name.toUTFz!( TCHAR * );
  }
}
private StockFont[] stockFonts;

static this() {
  stockFonts = [
    StockFont( OEM_FIXED_FONT, "OEM_FIXED_FONT" ),
    StockFont( ANSI_FIXED_FONT, "ANSI_FIXED_FONT" ),
    StockFont( ANSI_VAR_FONT, "ANSI_VAR_FONT" ),
    StockFont( SYSTEM_FONT, "SYSTEM_FONT" ),
    StockFont( DEVICE_DEFAULT_FONT, "DEVICE_DEFAULT_FONT" ),
    StockFont( DEFAULT_PALETTE, "DEFAULT_PALETTE" ),
    StockFont( SYSTEM_FIXED_FONT, "SYSTEM_FIXED_FONT" ),
  ];
}

extern( Windows ) nothrow LRESULT WndProc( HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam ) {
  static int fontIndex;
  int noFonts = stockFonts.length;
  TCHAR[ LF_FACESIZE ] faceName;
  TCHAR[ LF_FACESIZE + 64 ] buffer;
  /+static int cxChar, cxCaps, cyChar; //Average char width, caps width and char height respectively.
  static int cxClient, cyClient; //Current window size (width and height).
  static int maxWidth;+/
  
  HDC hdc;
  PAINTSTRUCT ps; 
  RECT rect;
  int cxGrid, cyGrid;
  TEXTMETRIC tm;
  //SCROLLINFO si;
  
  
  try {

    switch( message ) {
      case WM_CREATE:
        SetScrollRange( hwnd, SB_VERT, 0, noFonts - 1, true );
        return 0;
      case WM_DISPLAYCHANGE:
        InvalidateRect( hwnd, null, true );
        return 0;
      case WM_VSCROLL:
        switch( LOWORD( wParam ) ) {
          case SB_TOP:
            fontIndex = 0;
            break;
          case SB_BOTTOM:
            fontIndex = noFonts - 1;
            break;
          case SB_LINEUP:
          case SB_PAGEUP:
            --fontIndex;
            break;
          case SB_LINEDOWN:
          case SB_PAGEDOWN:
            ++fontIndex;
            break;
          case SB_THUMBTRACK:
            fontIndex = HIWORD( wParam );
            break;
          default:
        }
        SetScrollPos( hwnd, SB_VERT, fontIndex, true );
        if( fontIndex < 0 ) { 
          fontIndex = 0;
        } else if( noFonts - 1 < fontIndex ) {
          fontIndex = noFonts - 1;
        }
        InvalidateRect( hwnd, null, true );
        return 0;      
      case WM_KEYDOWN:
        switch( wParam ) {
          case VK_HOME:
            SendMessage( hwnd, WM_VSCROLL, SB_TOP, 0 );
            break;
          case VK_END:
            SendMessage( hwnd, WM_VSCROLL, SB_BOTTOM, 0 );
            break;
          case VK_PRIOR:
          case VK_LEFT:
          case VK_UP:
            SendMessage( hwnd, WM_VSCROLL, SB_LINEUP, 0 );
            break;
          case VK_NEXT:
          case VK_RIGHT:
          case VK_DOWN:
            SendMessage( hwnd, WM_VSCROLL, SB_LINEDOWN, 0 );
            break;
          default:
        }
        return 0;
      case WM_PAINT:
        //InvalidateRect( hwnd, null, true ); //Invalidate the whole client area.
        hdc = BeginPaint( hwnd, &ps );
        scope( exit ){ EndPaint( hwnd, & ps ); }
        SelectObject( hdc, GetStockObject( stockFonts[ fontIndex ].id ) );
        GetTextFace( hdc, LF_FACESIZE, faceName.ptr );
        GetTextMetrics( hdc, &tm );
        cxGrid = max( 3 * tm.tmAveCharWidth, 2 * tm.tmMaxCharWidth );
        cyGrid = tm.tmHeight + 3;
        TextOut( 
          hdc, 0, 0, buffer.ptr, 
          wsprintf( 
            buffer.ptr, TEXT( "%s: Face Name = %s, CharSet = %i" ),
            stockFonts[ fontIndex ].name, faceName.ptr, tm.tmCharSet 
          ) 
        );
        SetTextAlign( hdc, TA_TOP | TA_CENTER );
        //vertical and horizontal lines.
        for( int i = 0; i < 17; ++i ) {
          MoveToEx( hdc, ( i + 2 ) * cxGrid, 2 * cyGrid, null );
          LineTo( hdc, ( i + 2 ) * cxGrid, 19 * cyGrid );
          MoveToEx( hdc, cxGrid, ( i + 3 ) * cyGrid, null );
          LineTo( hdc, 18 * cxGrid, ( i + 3 )  * cyGrid );
        }
        //vertical and horizontal headings
        for( int i = 0; i < 16; ++i ) {
          TextOut( hdc, ( 2 * i + 5) * cxGrid / 2, 2 * cyGrid + 2, buffer.ptr,
            wsprintf( buffer.ptr, TEXT( "%X-" ), i ) 
           );
          TextOut( hdc, 3 * cxGrid / 2, ( i + 3 ) * cyGrid + 2, buffer.ptr,
            wsprintf( buffer.ptr, TEXT ("-%X"), i ) 
          );
        }
        // characters
        for( int y = 0; y < 16 ; ++y ) {
          for( int x = 0; x < 16 ; ++x ) {
            TextOut( 
              hdc, 
              ( 2 * x + 5 ) * cxGrid / 2, 
              ( y + 3 ) * cyGrid + 2, 
              buffer.ptr, 
              wsprintf( buffer.ptr, TEXT( "%c" ), 16 * x + y )
            );
          }
        }
        return 0;
      case WM_DESTROY:
        PostQuitMessage( 0 );
        return 0;    
      default:
        return DefWindowProc( hwnd, message, wParam, lParam );
    }
    assert( false );
  } catch( Throwable t ) {
    try { 
      writeln( "Message: ", t.msg, " File: ", t.file, " Line: ", t.line, " Info: ", t.info ); 
    } catch( Throwable t ) { ; }
  }
  assert( false );  
}

void register( ref WNDCLASS wndClass ) {
  if ( !RegisterClass( &wndClass ) ) { 
    throw new Exception( "Unable to register class" );
  }
}


int mainImpl( HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow ) {
  auto className = "Secret".toUTFz!( TCHAR * );
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
    "Stockfont".toUTFz!( TCHAR * ),  //Window caption.
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
      if (msg.message == WM_QUIT) { break; }      
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
  void exceptionHandler( Throwable e ) { throw e; }

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



