//
// input_keys
// Zig version: 
// Author: Nikolas Wipper
// Date: 2020-02-16
//
const std = @import("std");
const rl = @import("raylib");

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitAudioDevice();      // Initialize audio device
    rl.InitWindow(screenWidth, screenHeight, "raylib-zig [core] example - keyboard input");

    const texturePaths = [_][*c]const u8{
        "assets/playerIdle_1.png",
        "assets/playerIdle_2.png",
        "assets/playerIdle_3.png",
        "assets/playerIdle_4.png",
        "assets/playerIdle_5.png",
    };

    var textures: [texturePaths.len]rl.Texture2D = undefined; 
    for(&textures) |*item, i| {
        item.* = rl.LoadTexture(texturePaths[i]);
    }
    const MAX_TEXTURES: u64 = textures.len;

    const frameWidth = @intToFloat(f32,textures[0].width);
    const frameHeight = @intToFloat(f32, textures[0].height);

    // Source rectangle (part of the texture to use for drawing)
    const sourceRec = rl.Rectangle{ .x=0.0, .y=0.0, .width=frameWidth, .height=frameHeight };

    // Destination rectangle (screen rectangle where drawing part of texture)
    const destRec = rl.Rectangle{.x=screenWidth/2.0, .y=screenHeight/2.0, .width=frameWidth*2.0, .height=frameHeight*2.0 };

    // Origin of the texture (rotation/scale point), it's relative to destination rectangle size
    const origin = rl.Vector2{ .x= frameWidth, .y= frameHeight };

    var ballPosition = rl.Vector2 { .x = screenWidth/2, .y = screenHeight/2 };


    const fxWav: rl.Sound = rl.LoadSound("assets/player-character-death.mp3");         // Load audio file
    rl.SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.WindowShouldClose())   // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------

        if (rl.IsKeyPressed(rl.KeyboardKey.KEY_SPACE)) rl.PlaySound(fxWav);      // Play WAV sound
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_RIGHT)) { ballPosition.x += 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_LEFT)) { ballPosition.x -= 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_UP)) { ballPosition.y -= 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_DOWN)) { ballPosition.y += 2.0; }
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.BeginDrawing();

            rl.ClearBackground(rl.RAYWHITE);

            rl.DrawCircleV(ballPosition, 50, rl.MAROON);
            
            rl.DrawTexturePro(textures[@mod(@floatToInt(u64, rl.GetTime()*6), MAX_TEXTURES)], sourceRec, destRec, origin, 0.0, rl.WHITE);

        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }
    for(textures) |item| {
        rl.UnloadTexture(item);        // Texture unloading
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    rl.CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
