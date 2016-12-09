//
//  GraficoViewController.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 11/2/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//

import UIKit
import Charts

class GraficoViewController: UIViewController {
    @IBOutlet var chartView:BarChartView!
    var axisFormatDelegate: IAxisValueFormatter?
    
    var cpcUfsm:CPC!
    var cpcIes:CPC!
    var instituicaoSelecionada:Instituicao!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "Comparativo"
        self.axisFormatDelegate = self
        self.cpcIes = Util.getCPCInstituicao(inst: self.instituicaoSelecionada)
        
        var dataEntriesUfsm:[BarChartDataEntry] = []
        var dataEntriesOutras:[BarChartDataEntry] = []
        
        let valoresCPCUfsm = [cpcUfsm.notaPadronizadaEnade, cpcUfsm.notaPadronizadaIdd,
                              cpcUfsm.notaPadronizadaInfraestrutura, cpcUfsm.notaPadronizadaOrgDidaticaPedag,
                              cpcUfsm.notaPadronizadaOportunidadeAmp, cpcUfsm.notaPadronizadaDoutores,
                              cpcUfsm.notaPadronizadaMestres, cpcUfsm.notaPadronizadaRegTrabalho]
        
        let valoresCPCIes = [cpcIes.notaPadronizadaEnade, cpcIes.notaPadronizadaIdd,
                             cpcIes.notaPadronizadaInfraestrutura, cpcIes.notaPadronizadaOrgDidaticaPedag,
                             cpcIes.notaPadronizadaOportunidadeAmp, cpcIes.notaPadronizadaDoutores,
                             cpcIes.notaPadronizadaMestres, cpcIes.notaPadronizadaRegTrabalho]
        
        for index in 0...(valoresCPCUfsm.count - 1) {
            let x = BarChartDataEntry(x: Double(index), y: valoresCPCUfsm[index]!)
            dataEntriesUfsm.append(x)
        }
        
        for index in 0...(valoresCPCIes.count - 1) {
            let x = BarChartDataEntry(x: Double(index), y: valoresCPCIes[index]!)
            dataEntriesOutras.append(x)
        }
        
        let chartDataSetUfsm = BarChartDataSet(values: dataEntriesUfsm, label: "UFSM")
        chartDataSetUfsm.colors = [NSUIColor(colorLiteralRed: 0.9117, green: 0.1, blue: 0.1, alpha: 0.8)]
        
        let chartDataSetOutras = BarChartDataSet(values: dataEntriesOutras, label: instituicaoSelecionada.siglaIes)
        chartDataSetOutras.colors = [NSUIColor(colorLiteralRed: 0.0, green: 0.0, blue: 0.9117, alpha: 0.8)]
        
        let chartData = BarChartData(dataSets: [chartDataSetUfsm, chartDataSetOutras])
        chartData.barWidth = 0.35
        chartData.groupBars(fromX: -0.5, groupSpace: 0.20, barSpace: 0.05)
        
        chartView.data = chartData
        chartView.xAxis.labelPosition = .bottom
        chartView.chartDescription = Description()
        chartView.chartDescription?.text = ""
        chartView.fitBars = true
        chartView.highlighter = nil
        chartView.rightAxis.enabled = false
        chartView.xAxis.drawGridLinesEnabled = false
        chartView.animate(yAxisDuration: 1.5, easingOption: .easeInOutQuart)
        chartView.xAxis.valueFormatter = axisFormatDelegate
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
    }
}

extension GraficoViewController: IAxisValueFormatter {
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let v = Int(value)
        
        switch v {
            case 0:
                return "NE"
            case 1:
                return "IDD"
            case 2:
                return "NI"
            case 3:
                return "NO"
            case 4:
                return "NA"
            case 5:
                return "ND"
            case 6:
                return "NM"
            case 7:
                return "NT"
        
            default:
                return ""
        }
    }
    
}
