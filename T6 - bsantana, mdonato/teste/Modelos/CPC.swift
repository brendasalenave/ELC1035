//
//  CPC.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 07/09/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//

import Foundation

class CPC{
    var ano:Int!
    var idArea:Int!
    var idCentro:Int!
    var CPCContinuo:Double!
    var CPCF2013:Double!
    var CPCSimulado:Double!
    var notaPadronizadaEnade:Double!
    var notaPadronizadaIdd:Double!
    var notaPadronizadaInfraestrutura:Double!
    var notaPadronizadaOrgDidaticaPedag:Double!
    var notaPadronizadaDoutores:Double!
    var notaPadronizadaMestres:Double!
    var notaPadronizadaRegTrabalho:Double!
    var notaPadronizadaOportunidadeAmp:Double!
    var nomeIes:String!
    
    init() {
        self.ano = nil
        self.idArea = nil
        self.idCentro = nil
        self.CPCContinuo = nil
        self.CPCF2013 = nil
        self.CPCSimulado = nil
        self.notaPadronizadaEnade = nil
        self.notaPadronizadaIdd = nil
        self.notaPadronizadaInfraestrutura = nil
        self.notaPadronizadaOrgDidaticaPedag = nil
        self.notaPadronizadaDoutores = nil
        self.notaPadronizadaMestres = nil
        self.notaPadronizadaRegTrabalho = nil
        self.notaPadronizadaOportunidadeAmp = nil
        self.nomeIes = ""
    }
}
