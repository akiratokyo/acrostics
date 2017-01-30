//
//  ASKPCommon.h
//  AskingPoint
//
//  Copyright (c) 2015 KnowFu Inc. All rights reserved.
//

#define ASKP_VERSION @"4.1.6"
extern NSString * const ASKPVersion;

#if __has_feature(nullability)
#define ASKP_ASSUME_NONNULL_BEGIN _Pragma("clang assume_nonnull begin")
#define ASKP_ASSUME_NONNULL_END _Pragma("clang assume_nonnull end")
#define askp_nullable nullable
#define askp_nonnull nonnull
#define askp_null_unspecified null_unspecified
#define askp_null_resettable null_resettable
#define __askp_nullable __nullable
#define __askp_nonnull __nonnull
#define __askp_null_unspecified __null_unspecified
#else
#define ASKP_ASSUME_NONNULL_BEGIN
#define ASKP_ASSUME_NONNULL_END
#define askp_nullable
#define askp_nonnull
#define askp_null_unspecified
#define askp_null_resettable
#define __askp_nullable
#define __askp_nonnull
#define __askp_null_unspecified
#endif

#if __has_feature(objc_generics)
#define ASKP_GENERICS_AVAILABLE 1
#endif
