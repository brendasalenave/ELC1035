//
//  RankingViewController.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 17/09/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController {
    @IBOutlet var segmentedControlIes:UISegmentedControl!
    
    @IBOutlet var labelPosicaoBr:UILabel!
    @IBOutlet var labelPosicaoSul:UILabel!
    @IBOutlet var labelPosicaoRs:UILabel!
    
    @IBOutlet var labelTotalCursosBr:UILabel!
    @IBOutlet var labelTotalCursosSul:UILabel!
    @IBOutlet var labelTotalCursosRs:UILabel!
    
    @IBOutlet var labelPosicaoOriginalBr:UILabel!
    @IBOutlet var labelPosicaoOriginalSul:UILabel!
    @IBOutlet var labelPosicaoOriginalRs:UILabel!
    
    @IBOutlet var buttonPosicaoBr:UIButton!
    @IBOutlet var buttonPosicaoSul:UIButton!
    @IBOutlet var buttonPosicaoRs:UIButton!
    
    var indicador:Indicador!
    var curso:Curso!
    var cpc:CPC!
    var posicaoCalculada:PosicaoCalculada!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Ranking"
        
        self.indicador = Util.getIndicadorCurso(self.curso)
        self.posicaoCalculada = Util.calcularPosicao(self.curso, cpc: self.cpc)
        self.setDadosLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func alterarPublicaTodas() {
        if(self.segmentedControlIes.selectedSegmentIndex == 0){
            self.setDadosLabel()
        }else if(self.segmentedControlIes.selectedSegmentIndex == 1){
            self.setDadosLabel()
        }
    }
    
    @IBAction func exibirRank(_ sender:UIButton) {
        let classificacaoController = ClassificacaoViewController(nibName: "ClassificacaoViewController", bundle: nil)
        classificacaoController.cpc = self.cpc
        
        if(self.buttonPosicaoBr == sender){
            if(self.segmentedControlIes.selectedSegmentIndex == 0){
                classificacaoController.tipoSql = 0
            }else if(self.segmentedControlIes.selectedSegmentIndex == 1){
                classificacaoController.tipoSql = 3
            }
        }else if(self.buttonPosicaoSul == sender){
            if(self.segmentedControlIes.selectedSegmentIndex == 0){
                classificacaoController.tipoSql = 1
            }else if(self.segmentedControlIes.selectedSegmentIndex == 1){
                classificacaoController.tipoSql = 4
            }
        }else if(self.buttonPosicaoRs == sender){
            if(self.segmentedControlIes.selectedSegmentIndex == 0){
                classificacaoController.tipoSql = 2
            }else if(self.segmentedControlIes.selectedSegmentIndex == 1){
                classificacaoController.tipoSql = 5
            }
        }
        
        self.navigationController!.pushViewController(classificacaoController, animated: true)
    }

    func setDadosLabel() {
        switch self.segmentedControlIes.selectedSegmentIndex {
            case 0:
                self.labelPosicaoBr.text = String(self.posicaoCalculada.pos_br) + "º"
                self.labelTotalCursosBr.text = String(self.indicador.total_br)
                self.labelPosicaoOriginalBr.text = String(self.indicador.pos_br) + "º"
            
                self.labelPosicaoSul.text = String(self.posicaoCalculada.pos_sul) + "º"
                self.labelTotalCursosSul.text = String(self.indicador.total_sul)
                self.labelPosicaoOriginalSul.text = String(self.indicador.pos_sul) + "º"
            
                self.labelPosicaoRs.text = String(self.posicaoCalculada.pos_rs) + "º"
                self.labelTotalCursosRs.text = String(self.indicador.total_rs)
                self.labelPosicaoOriginalRs.text = String(self.indicador.pos_rs) + "º"
            
            case 1:
                self.labelPosicaoBr.text = String(self.posicaoCalculada.pos_pub_br)  + "º"
                self.labelTotalCursosBr.text = String(self.indicador.total_pub_br)
                self.labelPosicaoOriginalBr.text = String(self.indicador.pos_pub_br) + "º"
                
                self.labelPosicaoSul.text = String(self.posicaoCalculada.pos_pub_sul) + "º"
                self.labelTotalCursosSul.text = String(self.indicador.total_pub_sul)
                self.labelPosicaoOriginalSul.text = String(self.indicador.pos_pub_sul) + "º"
                
                self.labelPosicaoRs.text = String(self.posicaoCalculada.pos_pub_rs) + "º"
                self.labelTotalCursosRs.text = String(self.indicador.total_pub_rs)
                self.labelPosicaoOriginalRs.text = String(self.indicador.pos_pub_rs) + "º"
            
            default:
                break
        }
    }
}
