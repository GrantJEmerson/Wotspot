//
//  OfflineErrorPage.swift
//  Web Connect
//
//  Created by Grant Emerson on 1/3/18.
//  Copyright © 2018 Grant Emerson. All rights reserved.
//

import Foundation

class OfflineErrorPage {
    
    static let html =
    """
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
            font-size: 86px;
            font-weight: 700;
            line-height: 104px;
            margin: 0 auto;
        }

        .error-message, .suggestion-prompt {
            font-size: 40px;
            line-height: 55px;
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
                <p class="error-title">You Are Not Connected to a Web Share Session</p>
            </div>
            <div class="text-container">
                <!-- Error message here. -->
                <p class="error-message">Have a host add you to a Web Share session in order to surf the web.&nbsp;</p>
            </div>
        </div>
    </div>
    <div class="grammarly-disable-indicator"></div></body></html>
    """
}