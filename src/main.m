#import <Foundation/Foundation.h>
#include <raylib.h>
#include "raudio.h"
#include <zip.h>

int main(int argc, const char* argv[]) {
  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  if (argc < 2 || argc > 2) {
    NSLog(@"You must pass a single ZIP file.");
    return -1;
  }
  int openErr = 0;
  zip_t* archive = zip_open(argv[1], ZIP_RDONLY, &openErr);
  if (!archive) {
    zip_error_t ziperror;
    zip_error_init_with_code(&ziperror, openErr);
    fprintf(stderr, "Error opening zip: %s\n", zip_error_strerror(&ziperror));
    zip_error_fini(&ziperror);
    return 1;
  }
  NSLog(@"-- Starting window");
    InitWindow(640, 360, "RobjCwin");
    SetTargetFPS(60);
    InitAudioDevice();
    NSLog(@"-- Runtime loop");
    while (!WindowShouldClose()) {
      BeginDrawing();
        ClearBackground(BLACK);
        DrawText("Raylib window in Objective-C on RPI5", 160, 180, 20, RAYWHITE);
      EndDrawing();
    }
    NSLog(@"-- Closing window");
    CloseAudioDevice();
    CloseWindow();
  NSLog(@"-- Draining pool & returning 0");
  [pool drain];
  return 0;
}
