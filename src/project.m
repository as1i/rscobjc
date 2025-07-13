/**!
 * @todo
 *   Validate: comments
 *             broadcasts
 *             blocks
 *   Sprite2 and SB2 support
 *   SB1 Converter -> SB2
 *   SB2 Converter -> SB3
 */

#import "include/project.h"
#import <Foundation/Foundation.h>
#include <regex.h>
#include "cJSON.h"
#define cJSON_IsBoolean cJSON_IsBool
#define $str(x) [NSString stringWithUTF8String:x]
#include <stdlib.h>

BOOL _validate_reg(NSString* input, NSString* pattern) {
  NSError* error = nil;
  NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
  if (error) {
    [regex release];
    return NO;
  }
  NSRange range = NSMakeRange(0, input.length);
  NSTextCheckingResult* match = [regex firstMatchInString:input options:0 range:range];
  [regex release];
  if (match == nil) return NO;
  return YES;
}

int _validate_sprite3(const cJSON* p) {
  cJSON* temp = cJSON_GetObjectItemCaseSensitive(p, "isStage");
  if (temp == NULL || !cJSON_IsBoolean(temp)) return 1;
  const BOOL isStage = (BOOL)temp->valueint;
  temp = cJSON_GetObjectItemCaseSensitive(p, "name");
  if (temp == NULL || !cJSON_IsString(temp)) return 2;
  if (isStage && !strcmp(temp->valuestring, "Stage")) return 3;
  if (isStage) {
    temp = cJSON_GetObjectItemCaseSensitive(p, "tempo");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 4;
    temp = cJSON_GetObjectItemCaseSensitive(p, "videoTransparency");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 5;
    temp = cJSON_GetObjectItemCaseSensitive(p, "videoState");
    if (temp != NULL) {
      if (!cJSON_IsString(temp)) return 6;
      if (
        !strcmp(temp->valuestring, "on") &&
        !strcmp(temp->valuestring, "off") &&
        !strcmp(temp->valuestring, "on-flipped")
      ) return 7;
    }
    temp = cJSON_GetObjectItemCaseSensitive(p, "layerOrder");
    if (temp != NULL && (!cJSON_IsNumber(temp) || temp->valueint != 0)) return 8;
  } else {
    temp = cJSON_GetObjectItemCaseSensitive(p, "visible");
    if (temp != NULL && !cJSON_IsBoolean(temp)) return 9;
    temp = cJSON_GetObjectItemCaseSensitive(p, "x");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 10;
    temp = cJSON_GetObjectItemCaseSensitive(p, "y");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 11;
    temp = cJSON_GetObjectItemCaseSensitive(p, "size");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 12;
    temp = cJSON_GetObjectItemCaseSensitive(p, "direction");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 13;
    temp = cJSON_GetObjectItemCaseSensitive(p, "draggable");
    if (temp != NULL && !cJSON_IsBoolean(temp)) return 14;
    temp = cJSON_GetObjectItemCaseSensitive(p, "rotationStyle");
    if (temp != NULL) {
      if (!cJSON_IsString(temp)) return 15;
      if (
        !strcmp(temp->valuestring, "all around") &&
        !strcmp(temp->valuestring, "don't rotate") &&
        !strcmp(temp->valuestring, "left-right")
      ) return 16;
    }
    temp = cJSON_GetObjectItemCaseSensitive(p, "layerOrder");
    if (temp != NULL && (!cJSON_IsNumber(temp) || temp->valueint < 1)) return 17;
    temp = cJSON_GetObjectItemCaseSensitive(p, "volume");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 18;
  }

  const cJSON* blocks = cJSON_GetObjectItemCaseSensitive(p, "blocks");
  if (blocks == NULL || !cJSON_IsObject(blocks)) return 19;
  const cJSON* variables = cJSON_GetObjectItemCaseSensitive(p, "variables");
  if (variables == NULL || !cJSON_IsObject(variables)) return 20;
  const cJSON* costumes = cJSON_GetObjectItemCaseSensitive(p, "costumes");
  if (costumes == NULL || !cJSON_IsArray(costumes) || (cJSON_GetArraySize(costumes) < 1)) return 21;
  const cJSON* sounds = cJSON_GetObjectItemCaseSensitive(p, "sounds");
  if (sounds == NULL || !cJSON_IsArray(sounds)) return 22;

  cJSON* atemp = NULL;
  cJSON_ArrayForEach(atemp, variables) {
    if (!cJSON_IsArray(atemp)) return 23;
    const int size = cJSON_GetArraySize(variables);
    if (size > 3 || size < 2) return 23;
    cJSON* temp = cJSON_GetArrayItem(variables, 0);
    if (temp == NULL || !cJSON_IsString(temp)) return 23;
    temp = cJSON_GetArrayItem(variables, 1);
    if (temp == NULL) return 23;
    if (size > 2) {
      cJSON* temp = cJSON_GetArrayItem(variables, 2);
      if (temp == NULL || !cJSON_IsBoolean(temp)) return 23;
      if (!((BOOL)temp->valueint)) return 23;
    }
  }
  atemp = NULL;
  cJSON_ArrayForEach(atemp, costumes) {
    if (!cJSON_IsObject(atemp)) return 24;
    cJSON* temp = cJSON_GetObjectItemCaseSensitive(atemp, "assetId");
    if (temp == NULL || !cJSON_IsString(temp) || !_validate_reg(
      $str(temp->valuestring), @"^[a-fA-F0-9]{32}$"
    )) return 24;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "dataFormat");
    if (temp == NULL || !cJSON_IsString(temp)) return 24;
    if (
      !strcmp(temp->valuestring, "png") &&
      !strcmp(temp->valuestring, "svg") &&
      !strcmp(temp->valuestring, "jpeg") &&
      !strcmp(temp->valuestring, "jpg") &&
      !strcmp(temp->valuestring, "bmp") &&
      !strcmp(temp->valuestring, "gif")
    ) return 24;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "name");
    if (temp == NULL || !cJSON_IsString(temp)) return 24;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "bitmapResolution");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 24;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "rotationCenterX");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 24;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "rotationCenterY");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 24;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "md5ext");
    if (temp != NULL) {
      if (!cJSON_IsString(temp) || !_validate_reg(
        $str(temp->valuestring), @"^[a-fA-F0-9]{32}\\.[a-zA-Z]+$"
      )) return 24;
    }
  }
  atemp = NULL;
  cJSON_ArrayForEach(atemp, sounds) {
    if (!cJSON_IsObject(atemp)) return 25;
    cJSON* temp = cJSON_GetObjectItemCaseSensitive(atemp, "assetId");
    if (temp == NULL || !cJSON_IsString(temp) || !_validate_reg(
      $str(temp->valuestring), @"^[a-fA-F0-9]{32}$"
    )) return 25;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "dataFormat");
    if (temp == NULL || !cJSON_IsString(temp)) return 25;
    if (
      !strcmp(temp->valuestring, "wav") &&
      !strcmp(temp->valuestring, "wave") &&
      !strcmp(temp->valuestring, "mp3")
    ) return 25;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "name");
    if (temp == NULL || !cJSON_IsString(temp)) return 25;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "rate");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 25;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "sampleCount");
    if (temp != NULL && !cJSON_IsNumber(temp)) return 25;
    temp = cJSON_GetObjectItemCaseSensitive(atemp, "md5ext");
    if (temp != NULL) {
      if (!cJSON_IsString(temp) || !_validate_reg(
        $str(temp->valuestring), @"^[a-fA-F0-9]{32}\\.[a-zA-Z]+$"
      )) return 25;
    }
  }

  atemp = NULL;
  const cJSON* lists = cJSON_GetObjectItemCaseSensitive(p, "lists");
  if (lists != NULL) {
    if (!cJSON_IsArray(lists)) return 26;
    cJSON_ArrayForEach(atemp, lists) {
      if (!cJSON_IsArray(atemp)) return 26;
      const int size = cJSON_GetArraySize(atemp);
      if (size != 2) return 26;
      cJSON* temp = cJSON_GetArrayItem(atemp, 0);
      if (temp == NULL || !cJSON_IsString(temp)) return 26;
      temp = cJSON_GetArrayItem(atemp, 1);
      if (temp == NULL || !cJSON_IsArray(temp)) return 26;
    }
  } 


  // const cJSON* broadcasts = cJSON_GetObjectItemCaseSensitive(p, "broadcasts");
  // if (broadcasts != NULL && !cJSON_IsObject(broadcasts)) return 0;
  // const cJSON* comments = cJSON_GetObjectItemCaseSensitive(p, "comments");
  // if (comments != NULL && !cJSON_IsObject(comments)) return 0;

  return 0;
}

int validate_sb3(cJSON* p) {
  if (!cJSON_IsObject(p)) return 1;
  const cJSON* meta = cJSON_GetObjectItemCaseSensitive(p, "meta");
  if (meta == NULL || !cJSON_IsObject(meta)) return 2;
  const cJSON* targets = cJSON_GetObjectItemCaseSensitive(p, "targets");
  if (targets == NULL || !cJSON_IsArray(targets)) return 3;
  cJSON* temp = cJSON_GetObjectItemCaseSensitive(meta, "semver");
  if (temp == NULL || !cJSON_IsString(temp) || !_validate_reg(
    $str(temp->valuestring), @"^(3\\.[0-9]+\\.[0-9]+)$"
  )) return 4;
  temp = cJSON_GetObjectItemCaseSensitive(meta, "vm");
  if (temp != NULL) {
    if (!cJSON_IsString(temp) || !_validate_reg(
      $str(temp->valuestring), @"^([0-9]+\\.[0-9]+\\.[0-9]+)($|-)"
    )) return 5;
  }
  temp = cJSON_GetObjectItemCaseSensitive(meta, "agent");
  if (temp != NULL && !cJSON_IsString(temp)) return 6;
  temp = cJSON_GetObjectItemCaseSensitive(meta, "origin");
  if (temp != NULL && !cJSON_IsString(temp)) return 7;
  const cJSON* target = NULL;
  cJSON_ArrayForEach(target, temp) {
    if (!cJSON_IsObject(target)) return 40;
    const int test = _validate_sprite3(target);
    if (test != 0) return test + 40;
  }
  return 0;
}