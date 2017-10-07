
// includes for the editor
#include "VisualEditor_globals.agc"
#include "VisualEditor_load.agc"
#include "VisualEditor_scene.agc"
#include "VisualEditor_utilities.agc"

// set up the editor
VisualEditor_Setup ( VISUAL_EDITOR_LOAD_FOR_SCENE )

// go to the first scene
VisualEditor_SetScene ( 1 )

// utility functions to get ID and name from ID
// SpriteID = VisualEditor_GetID ( "sprite 1", 1 )	
// name$ = VisualEditor_GetNameFromID ( ID, VISUAL_EDITOR_SPRITE )
// kind = function VisualEditor_GetKind ( "sprite 1", 1 )

// our main loop
do
	// update the screen
	sync ( )	
loop
