package foxlite.flixel;

#if (funkin && polymod)
import funkin.modding.base.ScriptedFlxBasic;
class FoxExtendableBasic extends ScriptedFlxBasic {}
#else
typedef FoxExtendableBasic = flixel.FlxBasic;
#end