
//    raylib [shaders] example - Apply an shdrOutline to a texture

//    NOTE: This example requires raylib OpenGL 3.3 or ES2 versions for shaders support,
//          OpenGL 1.1 does not support shaders, recompile raylib to OpenGL 3.3 version.

//    Example originally created with raylib 4.0, last time updated with raylib 4.0

//    Example contributed by Samuel Skiff (@GoldenThumbs) and reviewed by Ramon Santamaria (@raysan5)

//    Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
//    BSD-like license that allows static linking with closed source software

//    Copyright (c) 2021-2023 Samuel SKiff (@GoldenThumbs) and Ramon Santamaria (@raysan5)


const rl = @import("raylib");
const std = @import("std");

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.InitWindow(screenWidth, screenHeight, "raylib [shaders] example - Apply an outline to a texture");

    const texture: rl.Texture2D = rl.LoadTexture("assets/playerIdle_1.png");
    
    const shdrOutline: rl.Shader = rl.LoadShader(0, rl.TextFormat("resources/shaders/outline.fs", @intCast(c_int, 330)));

    var outlineSize: f32 = 2.0;
    const outlineColor = [4]f32{ 1.0, 0.0, 0.0, 1.0 };     // Normalized RED color 
    const textureSize = rl.Vector2{ .x=@intToFloat(f32, texture.width), .y=@intToFloat(f32,texture.height) };
    
    // Get shader locations
    const outlineSizeLoc = rl.GetShaderLocation(shdrOutline, "outlineSize");
    const outlineColorLoc = rl.GetShaderLocation(shdrOutline, "outlineColor");
    const textureSizeLoc = rl.GetShaderLocation(shdrOutline, "textureSize");
    
    // Set shader values (they can be changed later)
    rl.SetShaderValue(shdrOutline, outlineSizeLoc, &outlineSize, @enumToInt(rl.ShaderUniformDataType.SHADER_UNIFORM_FLOAT));
    rl.SetShaderValue(shdrOutline, outlineColorLoc, &outlineColor, @enumToInt(rl.ShaderUniformDataType.SHADER_UNIFORM_VEC4));
    rl.SetShaderValue(shdrOutline, textureSizeLoc, &textureSize, @enumToInt(rl.ShaderUniformDataType.SHADER_UNIFORM_VEC2));

    rl.SetTargetFPS(60);               // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    // Main game loop
    while (!rl.WindowShouldClose())    // Detect window close button or ESC key
    {
        // Update
        //----------------------------------------------------------------------------------
        outlineSize += rl.GetMouseWheelMove();
        if (outlineSize < 1.0) outlineSize = 1.0;
        
        rl.SetShaderValue(shdrOutline, outlineSizeLoc, &outlineSize, @enumToInt(rl.ShaderUniformDataType.SHADER_UNIFORM_FLOAT));
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.BeginDrawing();

            rl.ClearBackground(rl.RAYWHITE);

            rl.BeginShaderMode(shdrOutline);
            
                rl.DrawTexture(texture, @divFloor(rl.GetScreenWidth(),2) - @divFloor(texture.width,2), -30, rl.WHITE);
                
            rl.EndShaderMode();

            // rl.DrawText("Shader-based\ntexture\noutline", 10, 10, 20, rl.GRAY);
            
            // rl.DrawText(rl.TextFormat("Outline size: %1.2f px", outlineSize), 10, 120, 20, rl.MAROON);
                // std.debug.print("{}\n", .{outlineSize});

            rl.DrawFPS(710, 10);

        rl.EndDrawing();
        //----------------------------------------------------------------------------------
    }

    // De-Initialization
    //--------------------------------------------------------------------------------------
    rl.UnloadTexture(texture);
    rl.UnloadShader(shdrOutline);

    rl.CloseWindow();        // Close window and OpenGL context
    //--------------------------------------------------------------------------------------

}