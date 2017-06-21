//
//  Vars.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 07/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//

import FirebaseRemoteConfig

struct Vars {
    
    // Color
    static let APP_COLOR = "#355dc4"
    
    
    
    // Main
    static let BASE_URL = FRCG().getS(name: "base_url")
    static let API_VERSION = FRCG().getS(name: "api_version")
    
    
    // My projects
    static let URL_PROJECTS_DELETE = BASE_URL + FRCG().getS(name: "url_projects_delete")
    static let URL_PROJECTS_SYNC = BASE_URL + API_VERSION + FRCG().getS(name: "url_sync")
    
    
    // API
    static let URL_API_2D = BASE_URL + API_VERSION + FRCG().getS(name: "url_api_2d")
    static let URL_API_3D = BASE_URL + API_VERSION + FRCG().getS(name: "url_api_3d")
    
    
    // Guides
    static let URL_GUIDES = FRCG().getS(name: "url_guides")
    
    
    // Archive
    static let URL_ARCHIVE = BASE_URL + API_VERSION + FRCG().getS(name: "url_archive")
    
    
    // Settings
    static let URL_SETTINGS_SAVE_NICK = BASE_URL + FRCG().getS(name: "url_settings_save_nick")
    
    
    // NSUserDefaults
    static let USERDEFAULT_NICK_NAME = FRCG().getS(name: "pref_nick")
    static let USERDEFAULT_NOTIFICATIONS = FRCG().getS(name: "pref_notifications")
    
    static let USERDEFAULT_EMAIL = FRCG().getS(name: "pref_email")
    static let USERDEFAULT_PASSWORD = FRCG().getS(name: "pref_password")


    // Comments
    static let URL_COMMENTS = BASE_URL + API_VERSION + FRCG().getS(name: "comments")
    static let URL_COMMENTS_ADD = BASE_URL + API_VERSION + FRCG().getS(name: "comments_send")
    
    
    // Profile
    static let URL_PROFILE = FRCG().getS(name: "url_profile")
    
    
   
    
    // Login
    static let URL_LOGIN = BASE_URL + FRCG().getS(name: "url_login")
    static let URL_LOGIN_FORGOT = BASE_URL + FRCG().getS(name: "url_login")
    static let URL_LOGIN_CREATE = BASE_URL + FRCG().getS(name: "url_login")
    
    static let URL_LOGIN_IMAGE = FRCG().getS(name: "url_login_image")
    static let URL_LOGIN_FORGOT_IMAGE = FRCG().getS(name: "url_login_forgot_image")
    static let URL_LOGIN_CREATE_IMAGE = FRCG().getS(name: "url_login_new_image")
    
    static let URL_LOGOUT = BASE_URL + FRCG().getS(name: "url_logout")
    static let URL_LOGIN_STAUS = BASE_URL + API_VERSION + FRCG().getS(name: "url_login_status")
    
    
    // Like/disslike
    static let URL_LIKE = BASE_URL + FRCG().getS(name: "url_like")
    static let URL_DISSLIKE = BASE_URL + FRCG().getS(name: "url_disslike")
    
    
    // Killswitch
    static let KILLSWITCH_ON = FRCG().getB(name: "killswitch_on")
    static let KILLSWITCH_TITLE = FRCG().getS(name: "killswitch_title")
    static let KILLSWITCH_DESCRIPTION = FRCG().getS(name: "killswitch_description")
    static let KILLSWITCH_ACTION = FRCG().getS(name: "killswitch_action")


    
    
}
