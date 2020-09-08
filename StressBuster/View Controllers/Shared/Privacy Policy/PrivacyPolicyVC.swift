//
//  PrivacyPolicyVC.swift
//  StressBuster
//
//  Created by Vamsikvkr on 8/10/20.
//  Copyright © 2020 StressBuster. All rights reserved.
//

import UIKit
import WebKit

class PrivacyPolicyVC: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var webViewText = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
    }
    
    fileprivate func configureUI() {
        webView.loadHTMLString(webViewText, baseURL: Bundle.main.bundleURL)
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
    }
}
