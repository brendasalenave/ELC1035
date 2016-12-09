//
//  ClassificacaoViewController.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 10/10/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//

import UIKit

class ClassificacaoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var listaInstituicoes:Array<Instituicao>!
    var cpc:CPC!
    var tipoSql:Int!
    @IBOutlet var tabView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Classificação"
        self.listaInstituicoes = Util.getListaInstituicoes(self.cpc, tipo: self.tipoSql)
        self.tabView.delegate = self
        self.tabView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listaInstituicoes.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        
        let colocacao = String(indexPath.row+1) + "º - "
        let cpc = String.init(format: "%.2f", self.listaInstituicoes[indexPath.row].CPCContinuo) + " - "
        
        cell.textLabel?.text = colocacao + cpc + self.listaInstituicoes[indexPath.row].siglaIes

        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let graficoController = GraficoViewController(nibName: "GraficoViewController", bundle: nil)
        
        graficoController.cpcUfsm = self.cpc
        graficoController.instituicaoSelecionada = listaInstituicoes[indexPath.row]
        
        self.navigationController!.pushViewController(graficoController, animated: true)
    }
}
