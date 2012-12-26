import std.stdio;
import std.conv;
import std.string;
import std.c.windows.windows;
import core.runtime;

extern (Windows)
int WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int iCmdShow) {
  int result;
  void exceptionHandler(Throwable e) { throw e; }

  try
  {
      Runtime.initialize(&exceptionHandler);
      result = mainImpl(hInstance, hPrevInstance, lpCmdLine, iCmdShow);
      Runtime.terminate(&exceptionHandler);
  }
  catch (Throwable o)
  {
      MessageBoxA( null, o.toString().toStringz, "Error", MB_OK | MB_ICONEXCLAMATION);
      result = 0;
  }

  return result;
}

int mainImpl( HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow) { 
  auto buttonPressed = MessageBoxA( 
    null, 
    //toStringz( "HInstance: " ~ to!string( hInstance ) ~ "\nHPrevInstance: " ~ to!string( hPrevInstance ) ~ "\n... You gay o' somn?" ),
    toStringz( "Ma chérie ö kanst du nìcht" ),
    toStringz( "HelloIsMe" ),
    MB_ABORTRETRYIGNORE | MB_DEFBUTTON1 | MB_ICONHAND
  );
  
  switch( buttonPressed ) {
    case IDOK:
      writeln( "You pressed OK... so you gay?" );
      break;
    case IDYES:
      writeln( "You pressed YES... so you gay?" );
      break;
    case IDNO:
      writeln( "You pressed NO... so you homophobic?" );
      break;
    case IDCANCEL:
      writeln( "You pressed CANCEL... now what kind of answer if that?" );
      break;
    case IDRETRY:
      writeln( "You pressed RETRY... retry what exactly?" );
      break;
    case IDABORT:
      writeln( "You pressed ABORT... ain't no way you getting away with this?" );
      break;
    case IDIGNORE:
      writeln( "You pressed IGNORE... so I guess you won, huh?" );
      break;
    default:
      throw new Exception( "Unknown button pressed: " ~ buttonPressed.to!string );
  }
  
  return 0;
}
 