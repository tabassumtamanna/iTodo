# iTodo

iTodo is a project for iOS Developer Nanodegree program at Udacity

[![Swift Version](https://img.shields.io/badge/Swift-5.3-brightgreen)](https://swift.org) [![Xcode Version](https://img.shields.io/badge/Xcode-12.1-success.svg)](https://swift.org) [![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](https://swift.org)

## Overview

In iTodo app, users can manage their to-do list and see the archive list. Archive list are group by dates.  

## Features

- Allow user to login using Google Authentication 
- Used Firebase for Data Persistence


## App Workflow

User has to login either using their google account. 

 <img src="/ScreenShots/login.png" width="200" />

Upon successfull login, users are redirected to app dashboard. 

In the dashboard navigation bar contains the profile picture in the left side and logout option on the right.

Also in the dashboard user will have the option to add a task using a input box followed by a add button.

After adding a task it will appear as a list in the dashboard followed by a checkbox. Checkbox allow user to check/uncheck a task.

<img src="/ScreenShots/dashboard.png" width="200" /> <img src="/ScreenShots/dashboard-with-completed-task.png" width="200" />

At the bottom of the dashboard there are two tabs: one is for the dashboard and another is the Archived List.

Archived List contains all old tasks group by the dates. 

In both list completed task are shown as grey and non completed task shown as black.

<img src="/ScreenShots/archived-list.png" width="200" />

User can remove any task from dashboard using swipe feature.

## Tools

- Xcode 12.1
- Swift
- Firebase
 
## Compatibility

 - iOS 7+

## Installation

Download and unzip ```iTodo```

### Cocoa Pods

This project uses CocoaPods for it's dependencies. To initalize the project you should first install CocoaPods and then initialize the dependencies by running

``` pod install ```

After that, open the project using the iTodo.xcworkspace.


