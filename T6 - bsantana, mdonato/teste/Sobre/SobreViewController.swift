//
//  SobreViewController.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 19/08/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//
// Testando script PSO

import UIKit

class SobreViewController: UIViewController {
    @IBOutlet var imgUfsm:UIImageView!
    @IBOutlet var viewContent:UIView!
    @IBOutlet var textHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Titulo da navbar
        self.title = "Sobre"

        // Define o tamanho do TextView dinamicamente
        self.textHeightConstraint!.constant = self.textViewHeightConstraintConstant()

        // Carrega o brasão da UFSM
        self.imgUfsm!.image = UIImage(named: "brasao.png")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func abrirGlossario(){
        let glossario = GlossarioViewController(nibName: "GlossarioViewController", bundle: nil)

        self.navigationController!.pushViewController(glossario, animated: true)
    }

    // Retorna o tamanho da tela
    func screenHeight() -> CGFloat {
        return UIScreen.main.bounds.height;
    }

    func textViewHeightConstraintConstant() -> CGFloat {
        switch(self.screenHeight()){
        case 568: // 4"
            return 140

        case 667: // 4,7"
            return 240

        case 736: // 5.5"
            return 240

        default: // 3,5"
            return 70
        }
    }

}
