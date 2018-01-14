//
//  OfflineErrorPage.swift
//  InterBrowse
//
//  Created by Grant Emerson on 1/3/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Foundation

final public class WebErrorPage {
    
    static let offline = htmlWith(title: "You Are Not Connected to a InterBrowse session",
                                  message: "Have a host add you to a InterBrowse session in order to surf the web.")
    static let notFound = htmlWith(title: "404 Page Not Found",
                                   message: "The page you are looking for either doesn't exist or is not here anymore.")
    
    internal class func htmlWith(title: String, message: String) -> String {
        
        var isMobile = true
        #if os(OSX)
            isMobile = false
        #endif
            
        return """
        <html class="gr__"><head>
        <style>
        body {font-family:'-apple-system-font';}
        body {
        background: rgb(246, 246, 246);
        cursor: default;
        display: -webkit-box;
        text-align: center;
        -webkit-box-align: center;
        -webkit-box-pack: center;
        -webkit-user-select: none;
        }
        
        a {
        color: rgb(21, 126, 251);
        text-decoration: none;
        }
        
        input {
        font-size: 16px;
        }
        
        .content-container {
        margin: 0 auto;
        position: relative;
        width: 80%;
        }
        
        .error-title {
        font-size: \(isMobile ? 86 : 28)px;
        font-weight: 700;
        line-height: \(isMobile ? 104 : 34)px;
        margin: 0 auto;
        }
        
        .error-message, .suggestion-prompt {
        font-size: \(isMobile ? 40 : 13)px;
        line-height: \(isMobile ? 55 : 18)px;
        padding: 0px 24px;
        }
        
        .suggestion-form {
        display: inline-block;
        margin: 5px;
        }
        
        .suggestion-form input {
        margin: 0;
        min-width: 146px;
        }
        
        .text-container {
        color: rgb(133, 133, 133);
        position: relative;
        width: 100%;
        word-wrap: break-word;
        }
        </style>
        <!-- LOCALIZERS: The next line contains the page title that appears in the window's title bar -->
        <title>Failed to open page</title>
        <style>.pkt_added {text-decoration:none !important;}</style></head>
        
        <body data-gr-c-s-loaded="true">
        <div class="content-container">
        <div class="error-container">
        <div class="text-container">
        <!-- Main title here. -->
        <p class="error-title">\(title)</p>
        </div>
        <div class="text-container">
        <!-- Error message here. -->
        <p class="error-message">\(message)&nbsp;</p>
        </div>
        </div>
        </div>
        <div class="grammarly-disable-indicator"></div></body></html>
        """
    }
}
