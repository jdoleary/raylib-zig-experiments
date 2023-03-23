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

    var camera = rl.Camera2D{ 
        .offset = rl.Vector2{.x = screenWidth/2, .y = screenHeight/2},
        .target = rl.Vector2{.x = screenWidth/2, .y = screenHeight/2},
        .rotation = 0,
        .zoom = 1.0,
    };

    // const shader = rl.LoadShader(0, rl.TextFormat("resources/shaders/grayscale.fs", @intCast(c_int, 330)));
    const shader = rl.LoadShader(0, rl.TextFormat("resources/shaders/waves.fs", @intCast(c_int, 330)));
    rl.SetShaderValue(shader, rl.GetShaderLocation(shader, "size"), &rl.Vector2{.x = 1.0, .y= 1.0}, @enumToInt(rl.ShaderUniformDataType.SHADER_UNIFORM_VEC2));
    const secondsLoc = rl.GetShaderLocation(shader, "seconds");
    const fxWav: rl.Sound = rl.LoadSound("assets/player-character-death.mp3");         // Load audio file
    rl.SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------
    var seconds:f32 = 0.0;

    // Main game loop
    while (!rl.WindowShouldClose())   // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        seconds += rl.GetFrameTime();

        rl.SetShaderValue(shader, secondsLoc, &seconds, @enumToInt(rl.ShaderUniformDataType.SHADER_UNIFORM_FLOAT));

        if (rl.IsKeyPressed(rl.KeyboardKey.KEY_SPACE)) rl.PlaySound(fxWav);      // Play WAV sound
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_RIGHT)) { ballPosition.x += 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_LEFT)) { ballPosition.x -= 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_UP)) { ballPosition.y -= 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_DOWN)) { ballPosition.y += 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_W)) { camera.target.y -= 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_A)) { camera.target.x -= 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_S)) { camera.target.y += 2.0; }
        if (rl.IsKeyDown(rl.KeyboardKey.KEY_D)) { camera.target.x += 2.0; }


        // Camera zoom controls
        camera.zoom += rl.GetMouseWheelMove()*0.05;

        if (camera.zoom > 3.0) { camera.zoom = 3.0;}
        else if (camera.zoom < 0.1) {camera.zoom = 0.1;}
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.BeginDrawing();

            rl.ClearBackground(rl.RAYWHITE);

            rl.BeginMode2D(camera);

            rl.DrawCircleV(ballPosition, 50, rl.MAROON);
            
            rl.BeginShaderMode(shader);
            rl.DrawTexturePro(textures[@mod(@floatToInt(u64, rl.GetTime()*6), MAX_TEXTURES)], sourceRec, destRec, origin, 0.0, rl.WHITE);
            rl.EndShaderMode();

            rl.EndMode2D();
        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }
    for(textures) |item| {
        rl.UnloadTexture(item);        // Texture unloading
    }
    rl.UnloadShader(shader);

    // De-Initialization
    //--------------------------------------------------------------------------------------
    rl.CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------
}
