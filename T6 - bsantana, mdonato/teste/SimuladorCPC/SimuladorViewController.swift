//
//  SimuladorViewController.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 19/08/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//

import UIKit

class SimuladorViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var centros:Array<Centro> = []
    var cursosCentro:Array<Curso> = []
    
    var cursoSelecionado:Curso!
    var cpc:CPC! = nil
    
    var pickerViewCentros = UIPickerView()
    var pickerViewCursosCentro = UIPickerView()
    
    @IBOutlet var logoImg:UIImageView!
    
    @IBOutlet var buttonRankBr:UIButton!
    @IBOutlet var buttonRankSul:UIButton!
    @IBOutlet var buttonRankRs:UIButton!
    
    @IBOutlet var scrollView:UIScrollView!
    
    @IBOutlet var textFieldCentro:UITextField!
    @IBOutlet var textFieldCurso:UITextField!
    
    @IBOutlet var labelNotaOriginalEnade:UILabel!
    @IBOutlet var labelNotaOriginalIdd:UILabel!
    @IBOutlet var labelNotaOriginalInfra:UILabel!
    @IBOutlet var labelNotaOriginalDidPedag:UILabel!
    @IBOutlet var labelNotaOriginalOportAmp:UILabel!
    @IBOutlet var labelNotaOriginalDocenteDr:UILabel!
    @IBOutlet var labelNotaOriginalDocenteMsc:UILabel!
    @IBOutlet var labelNotaOriginalDocentesRegTrab:UILabel!
    @IBOutlet var labelNotaOriginalCPC:UILabel!
    
    @IBOutlet var labelNotaCalculadaEnade:UILabel!
    @IBOutlet var labelNotaCalculadaIdd:UILabel!
    @IBOutlet var labelNotaCalculadaInfra:UILabel!
    @IBOutlet var labelNotaCalculadaDidPedag:UILabel!
    @IBOutlet var labelNotaCalculadaOportAmp:UILabel!
    @IBOutlet var labelNotaCalculadaDocenteDr:UILabel!
    @IBOutlet var labelNotaCalculadaDocenteMsc:UILabel!
    @IBOutlet var labelNotaCalculadaDocentesRegTrab:UILabel!
    @IBOutlet var labelNotaCalculadaCPC:UILabel!
    
    @IBOutlet var sliderEnade:UISlider!
    @IBOutlet var sliderIdd:UISlider!
    @IBOutlet var sliderInfra:UISlider!
    @IBOutlet var sliderDidPedag:UISlider!
    @IBOutlet var sliderOportAmp:UISlider!
    @IBOutlet var sliderDocenteDr:UISlider!
    @IBOutlet var sliderDocenteMsc:UISlider!
    @IBOutlet var sliderDocentesRegTrab:UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Calculadora"
        self.logoImg.image = UIImage(named: "ufsm2.png")
        
        self.centros = Util.getCentros()
        self.cursosCentro = Util.getCursosCentro(id: self.centros[0].idCentro)
        
        self.pickerViewCentros.delegate = self
        self.pickerViewCentros.dataSource = self
        self.textFieldCentro.inputView = self.pickerViewCentros
        
        self.pickerViewCursosCentro.delegate = self
        self.pickerViewCursosCentro.dataSource = self
        self.textFieldCurso.inputView = self.pickerViewCursosCentro
        
        // Configuracao inicial
        self.textFieldCentro.text = self.centros[0].siglaCentro
        self.textFieldCurso.text = self.cursosCentro[0].area
        self.setIndicadorCurso(self.cursosCentro[0])
        self.cursoSelecionado = self.cursosCentro[0]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        self.scrollView.contentSize.height = 500
        self.preferredContentSize.height = 600
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == self.pickerViewCentros){
            return self.centros.count
        }else{
            return self.cursosCentro.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == self.pickerViewCentros){
            self.textFieldCentro.text = self.centros[row].siglaCentro
            self.cursosCentro.removeAll()
            self.cursosCentro = Util.getCursosCentro(id: self.centros[row].idCentro)
            self.cursoSelecionado = self.cursosCentro[0]
            self.textFieldCurso.text = self.cursosCentro[0].area
            self.setIndicadorCurso(self.cursosCentro[0])
        }else{
            self.textFieldCurso.text = self.cursosCentro[row].area
            self.setIndicadorCurso(self.cursosCentro[row])
            self.cursoSelecionado = self.cursosCentro[row]
        }
        
        self.view.endEditing(true)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == self.pickerViewCentros){
            return self.centros[row].siglaCentro
        }else{
            return self.cursosCentro[row].area
        }
        
    }
    
    func setIndicadorCurso(_ curso:Curso) {
        self.cpc = Util.getCpcCurso(curso: curso)
        
        if(cpc.ano < 2013) {
            self.view.endEditing(true)
            
            let alertController = UIAlertController(title: "Atenção", message: "Curso avaliado antes de 2013!\n Pode haver diferenças entre o CPC Contínuo e o CPC Calculado", preferredStyle: UIAlertControllerStyle.alert)
            let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
            
            alertController.addAction(action)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
        self.labelNotaOriginalCPC.text = String.init(format: "%.2f", self.cpc.CPCContinuo)
        self.labelNotaOriginalEnade.text = String.init(format: "%.2f", self.cpc.notaPadronizadaEnade)
        self.labelNotaOriginalIdd.text = String.init(format: "%.2f", self.cpc.notaPadronizadaIdd)
        self.labelNotaOriginalInfra.text = String.init(format: "%.2f", self.cpc.notaPadronizadaInfraestrutura)
        self.labelNotaOriginalDidPedag.text = String.init(format: "%.2f", self.cpc.notaPadronizadaOrgDidaticaPedag)
        self.labelNotaOriginalOportAmp.text = String.init(format: "%.2f", self.cpc.notaPadronizadaOportunidadeAmp)
        self.labelNotaOriginalDocenteDr.text = String.init(format: "%.2f", self.cpc.notaPadronizadaDoutores)
        self.labelNotaOriginalDocenteMsc.text = String.init(format: "%.2f", self.cpc.notaPadronizadaMestres)
        self.labelNotaOriginalDocentesRegTrab.text = String.init(format: "%.2f", self.cpc.notaPadronizadaRegTrabalho)
        
        self.sliderEnade.setValue(Float.init(self.cpc.notaPadronizadaEnade), animated: false)
        self.sliderIdd.setValue(Float.init(self.cpc.notaPadronizadaIdd), animated: false)
        self.sliderInfra.setValue(Float.init(self.cpc.notaPadronizadaInfraestrutura), animated: false)
        self.sliderDidPedag.setValue(Float.init(self.cpc.notaPadronizadaOrgDidaticaPedag), animated: false)
        self.sliderOportAmp.setValue(Float.init(self.cpc.notaPadronizadaOportunidadeAmp), animated: false)
        self.sliderDocenteDr.setValue(Float.init(self.cpc.notaPadronizadaDoutores), animated: false)
        self.sliderDocenteMsc.setValue(Float.init(self.cpc.notaPadronizadaMestres), animated: false)
        self.sliderDocentesRegTrab.setValue(Float.init(self.cpc.notaPadronizadaRegTrabalho), animated: false)
        
        self.labelNotaCalculadaCPC.text = String.init(format: "%.2f", self.cpc.CPCF2013)
        self.labelNotaCalculadaEnade.text = String.init(format: "%.2f", self.cpc.notaPadronizadaEnade)
        self.labelNotaCalculadaIdd.text = String.init(format: "%.2f", self.cpc.notaPadronizadaIdd)
        self.labelNotaCalculadaInfra.text = String.init(format: "%.2f", self.cpc.notaPadronizadaInfraestrutura)
        self.labelNotaCalculadaDidPedag.text = String.init(format: "%.2f", self.cpc.notaPadronizadaOrgDidaticaPedag)
        self.labelNotaCalculadaOportAmp.text = String.init(format: "%.2f", self.cpc.notaPadronizadaOportunidadeAmp)
        self.labelNotaCalculadaDocenteDr.text = String.init(format: "%.2f", self.cpc.notaPadronizadaDoutores)
        self.labelNotaCalculadaDocenteMsc.text = String.init(format: "%.2f", self.cpc.notaPadronizadaMestres)
        self.labelNotaCalculadaDocentesRegTrab.text = String.init(format: "%.2f", self.cpc.notaPadronizadaRegTrabalho)
    }
    
    @IBAction func calcularCPC(_ sender: UISlider) {
        let nc:Float = self.sliderEnade.value
        let nidd:Float = self.sliderIdd.value
        let nm:Float = self.sliderDocenteMsc.value
        let nd:Float = self.sliderDocenteDr.value
        let nr:Float = self.sliderDocentesRegTrab.value
        let no:Float = self.sliderDidPedag.value
        let nf:Float = self.sliderInfra.value
        let na:Float = self.sliderOportAmp.value
        
        let cpc:Float = nc*0.20 + nidd*0.35 + nm*0.075 + nd*0.15 + nr*0.075 + no*0.075 + nf*0.05 + na*0.025
        self.cpc.CPCSimulado = Double.init(cpc)
        
        self.labelNotaCalculadaCPC.text = String.init(format: "%.2f", cpc)
        self.labelNotaCalculadaEnade.text = String.init(format: "%.2f", nc)
        self.labelNotaCalculadaIdd.text = String.init(format: "%.2f", nidd)
        self.labelNotaCalculadaInfra.text = String.init(format: "%.2f", nf)
        self.labelNotaCalculadaDidPedag.text = String.init(format: "%.2f", no)
        self.labelNotaCalculadaOportAmp.text = String.init(format: "%.2f", na)
        self.labelNotaCalculadaDocenteDr.text = String.init(format: "%.2f", nd)
        self.labelNotaCalculadaDocenteMsc.text = String.init(format: "%.2f", nm)
        self.labelNotaCalculadaDocentesRegTrab.text = String.init(format: "%.2f", nr)
    }
    
    @IBAction func posicionarCurso() {
        let ranking = RankingViewController(nibName: "RankingViewController", bundle: nil)
        
        ranking.indicador = Util.getIndicadorCurso(self.cursoSelecionado)
        ranking.curso = self.cursoSelecionado
        ranking.cpc = self.cpc
        
        self.navigationController!.pushViewController(ranking, animated: true)
    }
 
    @IBAction func resetarCPC() {
        self.cpc.CPCSimulado = self.cpc.CPCContinuo
        
        self.sliderEnade.setValue(Float.init(self.cpc.notaPadronizadaEnade), animated: false)
        self.sliderIdd.setValue(Float.init(self.cpc.notaPadronizadaIdd), animated: false)
        self.sliderInfra.setValue(Float.init(self.cpc.notaPadronizadaInfraestrutura), animated: false)
        self.sliderDidPedag.setValue(Float.init(self.cpc.notaPadronizadaOrgDidaticaPedag), animated: false)
        self.sliderOportAmp.setValue(Float.init(self.cpc.notaPadronizadaOportunidadeAmp), animated: false)
        self.sliderDocenteDr.setValue(Float.init(self.cpc.notaPadronizadaDoutores), animated: false)
        self.sliderDocenteMsc.setValue(Float.init(self.cpc.notaPadronizadaMestres), animated: false)
        self.sliderDocentesRegTrab.setValue(Float.init(self.cpc.notaPadronizadaRegTrabalho), animated: false)
        
        self.labelNotaCalculadaCPC.text = String.init(format: "%.2f", self.cpc.CPCContinuo)
        self.labelNotaCalculadaEnade.text = String.init(format: "%.2f", self.cpc.notaPadronizadaEnade)
        self.labelNotaCalculadaIdd.text = String.init(format: "%.2f", self.cpc.notaPadronizadaIdd)
        self.labelNotaCalculadaInfra.text = String.init(format: "%.2f", self.cpc.notaPadronizadaInfraestrutura)
        self.labelNotaCalculadaDidPedag.text = String.init(format: "%.2f", self.cpc.notaPadronizadaOrgDidaticaPedag)
        self.labelNotaCalculadaOportAmp.text = String.init(format: "%.2f", self.cpc.notaPadronizadaOportunidadeAmp)
        self.labelNotaCalculadaDocenteDr.text = String.init(format: "%.2f", self.cpc.notaPadronizadaDoutores)
        self.labelNotaCalculadaDocenteMsc.text = String.init(format: "%.2f", self.cpc.notaPadronizadaMestres)
        self.labelNotaCalculadaDocentesRegTrab.text = String.init(format: "%.2f", self.cpc.notaPadronizadaRegTrabalho)

    }
}
