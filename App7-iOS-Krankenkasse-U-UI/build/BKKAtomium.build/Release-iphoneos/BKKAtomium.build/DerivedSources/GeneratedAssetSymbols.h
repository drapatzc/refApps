#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "ad-dental" asset catalog image resource.
static NSString * const ACImageNameAdDental AC_SWIFT_PRIVATE = @"ad-dental";

/// The "ad-health-tips" asset catalog image resource.
static NSString * const ACImageNameAdHealthTips AC_SWIFT_PRIVATE = @"ad-health-tips";

/// The "ad-mental-health" asset catalog image resource.
static NSString * const ACImageNameAdMentalHealth AC_SWIFT_PRIVATE = @"ad-mental-health";

/// The "ad-wellness" asset catalog image resource.
static NSString * const ACImageNameAdWellness AC_SWIFT_PRIVATE = @"ad-wellness";

/// The "hero-login" asset catalog image resource.
static NSString * const ACImageNameHeroLogin AC_SWIFT_PRIVATE = @"hero-login";

/// The "hero-mountain" asset catalog image resource.
static NSString * const ACImageNameHeroMountain AC_SWIFT_PRIVATE = @"hero-mountain";

#undef AC_SWIFT_PRIVATE
