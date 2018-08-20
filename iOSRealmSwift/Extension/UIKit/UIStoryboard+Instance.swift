//
//  UIStoryboard+Instance.swift
//  iOSRealmSwift
//
//  Created by YukiOkudera on 2018/08/20.
//  Copyright © 2018年 YukiOkudera. All rights reserved.
//

import UIKit

extension UIStoryboard {
    
    /// Storyboardからインスタンスを取得する
    class func viewController<T: UIViewController>(storyboardName: String,
                                                   identifier: String) -> T? {
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T
    }
}
