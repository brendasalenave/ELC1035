//
//  Curso.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 02/09/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//

import Foundation

class Curso{
    var idCentro:Int
    var area:String
    var idArea:Int
    var ano:Int
    
    init(centro:Int, nome:String, id:Int, ano:Int) {
        self.idCentro = centro
        self.area = nome
        self.idArea = id
        self.ano = ano
    }
}