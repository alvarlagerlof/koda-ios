//
//  Vars.swift
//  koda.nu
//
//  Created by Alvar Lagerlöf on 07/11/16.
//  Copyright © 2016 Alvar Lagerlöf. All rights reserved.
//


struct Vars {
    
    // Main
    static let BASE_URL = "http://koda.nu/";
    static let API_VERSION = "api_v1/";
    
    
    // My projects
    static let URL_PROJECTS = BASE_URL + API_VERSION + "labbet"
    static let URL_PROJECTS_CREATE_NEW = BASE_URL + API_VERSION + "skapa";
    static let URL_PROJECTS_EDIT = BASE_URL + "labbet/"
    static let URL_PROJECTS_DELETE = BASE_URL + "delete/"
    
    
    // API
    static let URL_API_2D = BASE_URL + API_VERSION + "api_2d"
    static let URL_API_3D = BASE_URL + API_VERSION + "api_3d"
    
    
    // Guides
    static let URL_GUIDES = "https://ravla.org/guider.json"
    
    
    // Archive
    static let URL_ARCHIVE = BASE_URL + API_VERSION + "arkivet"
    
    
    // Settings
    static let URL_SETTINGS_SAVE_NICK = BASE_URL + "labbet"
    
    
    // NSUserDefaults
    static let USERDEFAULT_FIRST_START = "FIRST_START"
    static let USERDEFAULT_NICK_NAME = "NICK_NAME"
    static let USERDEFAULT_NOTIFICATIONS = "NOTIFICATIONS"
    
    static let USERDEFAULT_EMAIL = "EMAIL"
    static let USERDEFAULT_PASSWORD = "PASSWORD"


    // Comments
    static let URL_COMMENTS = BASE_URL + API_VERSION + "kommentera/"
    static let URL_COMMENTS_ADD = BASE_URL + API_VERSION + "kommentera/"
    
    
    // Profile
    static let URL_PROFILE = "https://ravla.org/profile.txt"  // TODO: NOT DONE YET
    
    
    // Other
    static let URL_LIKE = BASE_URL + "plus/"
    static let URL_DISSLIKE = BASE_URL + "minus/"
    
    // Login
    static let URL_LOGIN = BASE_URL + "login"
    static let URL_LOGIN_FORGOT = BASE_URL + "login"
    static let URL_LOGIN_CREATE = BASE_URL + "login"
    
    static let URL_LOGIN_IMAGE = "https://hd.unsplash.com/photo-1461749280684-dccba630e2f6"
    static let URL_LOGIN_FORGOT_IMAGE = "https://hd.unsplash.com/photo-1461632830798-3adb3034e4c8"
    static let URL_LOGIN_CREATE_IMAGE = "https://hd.unsplash.com/photo-1429051883746-afd9d56fbdaf"
    
    
    // Editor
    static let URL_EDITOR_SAVE = BASE_URL + "labbet/"
    
}
