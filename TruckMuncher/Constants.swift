//
//  Constants.swift
//  TruckMuncher
//
//  Created by Josh Ault on 9/22/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import Foundation

/*
 * Non-value constants (such as keys into a dictionary) start with a k and are camel case
 */
let kTwitterOauthVerifier = "oauth_verifier"
let kTwitterOauthToken = "oauth_token"
let kTwitterOauthSecret = "oauth_secret"

let kTwitterCallback = "twitter_callback"
let kTwitterName = "twitter_name"
let kTwitterKey = "twitter_key"
let kTwitterSecretKey = "twitter_secret_key"

let kCrashlyticsKey = "crashlytics_key"

/*
 * Constants holding real values used directly should take on the typical syntax that #define used in obj-c
 */
let MENU_CATEGORY_HEIGHT:CGFloat = 66.0

#if RELEASE
let PROPERTIES_FILE = "Properties"
let BASE_URL = "https://api.truckmuncher.com:8443"
#elseif DEBUG
let PROPERTIES_FILE = "Properties-dev"
let BASE_URL = "https://api.truckmuncher.com:8443"

//let BASE_URL = "http://truckmuncher:8443"
#endif
