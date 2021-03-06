/*
 *     Generated by class-dump 3.1.2.
 *
 *     class-dump is Copyright (C) 1997-1998, 2000-2001, 2004-2007 by Steve Nygard.
 */

#import "NSObject.h"

@interface PSKeychainUtilities : NSObject
{
}

+ (id)_passwordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(id)fp20;
+ (id)passwordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(id)fp20;
+ (void)setPassword:(id)fp8 forHost:(id)fp12 username:(id)fp16 port:(int)fp20 protocol:(id)fp24;
+ (void)removePasswordForHost:(id)fp8 username:(id)fp12 port:(int)fp16 protocol:(id)fp20;
+ (id)_passwordForGenericAccount:(id)fp8 service:(id)fp12;
+ (id)passwordForServiceName:(id)fp8 accountName:(id)fp12;
+ (void)setPassword:(id)fp8 forServiceName:(id)fp12 accountName:(id)fp16;
+ (void)removePasswordForServiceName:(id)fp8 accountName:(id)fp12;

@end

