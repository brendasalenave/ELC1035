//
//  GlossarioViewController.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 19/08/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//

import UIKit

class GlossarioViewController: UIViewController {
    @IBOutlet var glossario:UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Glossário"
        
        // Carrega o glossario.html na webview
        let path = Bundle.main.path(forResource: "glossario", ofType: "html")!
        let url = URL(fileURLWithPath: path)
        let request = URLRequest(url: url)
        
        self.glossario.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
