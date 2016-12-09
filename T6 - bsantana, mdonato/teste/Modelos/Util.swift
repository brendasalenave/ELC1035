//
//  Util.swift
//  SmartCPC
//
//  Created by Mauricio M. Donato on 31/08/16.
//  Copyright © 2016 Mauricio M. Donato. All rights reserved.
//

import Foundation

class Util{
    class func getCentros() -> [Centro] {
        var centros:Array<Centro> = []
        let database:SQLiteHelper = SQLiteHelper(database: "cpc")
        
        database.abrirDatabase()
        let rs:FMResultSet = database.executarQuery("SELECT sigla, id_centro FROM CENTRO", valores: nil)
        while(rs.next()){
            let c:Centro = Centro(sigla: rs.string(forColumn: "sigla"), id: Int.init(rs.int(forColumn: "id_centro")))
            centros.append(c)
        }
        database.fecharDatabase()
        
        return centros
    }
    
    class func getCursosCentro(id:Int) -> [Curso] {
        var cursos:Array<Curso> = []
        let database:SQLiteHelper = SQLiteHelper(database: "cpc")
        
        database.abrirDatabase()
        let rs:FMResultSet = database.executarQuery("SELECT Area, ID_AREA, max(Ano) FROM cpcAll WHERE id_ies == 582 AND id_centro == ? GROUP BY Area ORDER BY Area ", valores: [id as AnyObject])
        while(rs.next()){
            let c:Curso = Curso(centro: id,
                                nome: rs.string(forColumn: "Area"),
                                id: Int.init(rs.int(forColumn: "ID_AREA")),
                                ano: Int.init(rs.int(forColumn: "max(Ano)")))
            cursos.append(c)
        }
        database.fecharDatabase()
        
        return cursos
    }
    
    class func getCpcCurso(curso:Curso) -> CPC {
        let database:SQLiteHelper = SQLiteHelper(database: "cpc")
        let cpc:CPC = CPC()
        
        database.abrirDatabase()
        let rs:FMResultSet = database.executarQuery("SELECT CPC_Continuo, CPC_F2013, Nota_Continua_Enade, Nota_Padronizada_IDD, Nota_Padronizada_Infraestrutura, Nota_Padronizada_Organ_Did_Pedag, Nota_Padronizada_Oport_Amplia, Nota_Padronizada_Doutores, Nota_Padronizada_Mestres, Nota_Padronizada_Regime_Trabalho FROM CpcAll JOIN Indicadores_ufsm ON (CpcAll.Ano = Indicadores_ufsm.ano AND CpcAll.id_Area = Indicadores_ufsm.id_area AND CpcAll.id_centro = Indicadores_ufsm.id_centro) WHERE id_ies == 582 AND id_Indicador == 1 AND CpcAll.ano == ? AND CpcAll.id_centro == ? AND CpcAll.id_area == ?", valores: [curso.ano as AnyObject, curso.idCentro as AnyObject, curso.idArea as AnyObject])
        while(rs.next()){
            cpc.ano = curso.ano
            cpc.idCentro = curso.idCentro
            cpc.idArea = curso.idArea
            cpc.CPCContinuo = rs.double(forColumn: "CPC_Continuo")
            
            if(rs.columnIsNull("CPC_F2013")){
                cpc.CPCF2013 = 0.0
            }else{
                cpc.CPCF2013 = rs.double(forColumn: "CPC_F2013")
            }
            
            cpc.notaPadronizadaEnade = rs.double(forColumn: "Nota_Continua_Enade")
            cpc.notaPadronizadaIdd = rs.double(forColumn: "Nota_Padronizada_IDD")
            cpc.notaPadronizadaInfraestrutura = rs.double(forColumn: "Nota_Padronizada_Infraestrutura")
            cpc.notaPadronizadaOrgDidaticaPedag = rs.double(forColumn: "Nota_Padronizada_Organ_Did_Pedag")
            cpc.notaPadronizadaOportunidadeAmp = rs.double(forColumn: "Nota_Padronizada_Oport_Amplia")
            cpc.notaPadronizadaDoutores = rs.double(forColumn: "Nota_Padronizada_Doutores")
            cpc.notaPadronizadaMestres = rs.double(forColumn: "Nota_Padronizada_Mestres")
            cpc.notaPadronizadaRegTrabalho = rs.double(forColumn: "Nota_Padronizada_Regime_Trabalho")
        }
        cpc.CPCSimulado = cpc.CPCContinuo
        database.fecharDatabase()
        
        return cpc
    }
    
    class func getIndicadorCurso(_ curso:Curso) -> Indicador {
        let indicador:Indicador = Indicador()
        let database:SQLiteHelper = SQLiteHelper(database: "cpc")
        
        database.abrirDatabase()
        let rs:FMResultSet = database.executarQuery("SELECT i1.id_indicador as id, label_indicador, Valor_Indicador, pos_br, pos_sul, pos_rs, pos_pub_br, pos_pub_sul, pos_pub_rs, total_br, total_sul, total_rs, total_pub_br, total_pub_sul, total_pub_rs FROM indicadores_ufsm i1 join indicadores i2  on i1.id_indicador = i2.id_indicador and ano == ? AND id_centro == ? AND id_area == ?", valores: [curso.ano as AnyObject, curso.idCentro as AnyObject, curso.idArea as AnyObject])
        
        while(rs.next()){
            indicador.pos_br = Int.init(rs.int(forColumn: "pos_br"))
            indicador.pos_sul = Int.init(rs.int(forColumn: "pos_sul"))
            indicador.pos_rs = Int.init(rs.int(forColumn: "pos_rs"))
            
            indicador.pos_pub_br = Int.init(rs.int(forColumn: "pos_pub_br"))
            indicador.pos_pub_sul = Int.init(rs.int(forColumn: "pos_pub_sul"))
            indicador.pos_pub_rs = Int.init(rs.int(forColumn: "pos_pub_rs"))
            
            indicador.total_br = Int.init(rs.int(forColumn: "total_br"))
            indicador.total_sul = Int.init(rs.int(forColumn: "total_sul"))
            indicador.total_rs = Int.init(rs.int(forColumn: "total_rs"))
            
            indicador.total_pub_br = Int.init(rs.int(forColumn: "total_pub_br"))
            indicador.total_pub_sul = Int.init(rs.int(forColumn: "total_pub_sul"))
            indicador.total_pub_rs = Int.init(rs.int(forColumn: "total_pub_rs"))
        }
        database.fecharDatabase()
        
        return indicador
    }

    class func calcularPosicao(_ curso:Curso, cpc:CPC) -> PosicaoCalculada {
        let posicao:PosicaoCalculada = PosicaoCalculada()
        let database:SQLiteHelper = SQLiteHelper(database: "cpc")
        
        database.abrirDatabase()
        var rs:FMResultSet = database.executarQuery("SELECT i1.total as BR FROM (SELECT count(cpc_continuo) as total FROM cpcALL WHERE cpc_continuo > ? AND (id_centro IS NULL OR id_centro != ?) AND id_area == ? AND ano == ?) as i1", valores: [cpc.CPCSimulado as AnyObject, curso.idCentro as AnyObject, curso.idArea as AnyObject, curso.ano as AnyObject])

        while(rs.next()){
            posicao.pos_br = Int.init(rs.int(forColumn: "BR")) + 1
        }
        
        rs = database.executarQuery("SELECT i2.total as SUL FROM (SELECT count(cpc_continuo) as total FROM cpcALL WHERE cpc_continuo > ? AND (id_centro IS NULL OR id_centro != ?) AND id_area == ? AND ano == ? AND regiao == 1) as i2", valores: [cpc.CPCSimulado as AnyObject, curso.idCentro as AnyObject, curso.idArea as AnyObject, curso.ano as AnyObject])
        
        while(rs.next()){
            posicao.pos_sul = Int.init(rs.int(forColumn: "SUL")) + 1
        }
        
        rs = database.executarQuery("SELECT i3.total as RS FROM (SELECT count(cpc_continuo) as total FROM cpcALL WHERE cpc_continuo > ? AND (id_centro IS NULL OR id_centro != ?) AND id_area == ? AND ano == ? AND UF == 'RS') as i3", valores: [cpc.CPCSimulado as AnyObject, curso.idCentro as AnyObject, curso.idArea as AnyObject, curso.ano as AnyObject])
        
        while(rs.next()){
            posicao.pos_rs = Int.init(rs.int(forColumn: "RS")) + 1
        }
        
        rs = database.executarQuery("SELECT i4.total as BR_PUB FROM (SELECT count(cpc_continuo) as total FROM cpcALL WHERE cpc_continuo > ? AND (id_centro IS NULL OR id_centro != ?) AND id_area == ? AND ano == ? AND publico == 1) as i4", valores: [cpc.CPCSimulado as AnyObject, curso.idCentro as AnyObject, curso.idArea as AnyObject, curso.ano as AnyObject])
        
        while(rs.next()){
            posicao.pos_pub_br = Int.init(rs.int(forColumn: "BR_PUB")) + 1
        }
        
        rs = database.executarQuery("SELECT i5.total as SUL_PUB FROM  (SELECT count(cpc_continuo) as total FROM cpcALL WHERE cpc_continuo > ? AND (id_centro IS NULL OR id_centro != ?) AND id_area == ? AND ano == ? AND publico == 1 AND regiao == 1) as i5", valores: [cpc.CPCSimulado as AnyObject, curso.idCentro as AnyObject, curso.idArea as AnyObject, curso.ano as AnyObject])
        
        while(rs.next()){
            posicao.pos_pub_sul = Int.init(rs.int(forColumn: "SUL_PUB")) + 1
        }
        
        rs = database.executarQuery("SELECT i6.total as RS_PUB FROM (SELECT count(cpc_continuo) as total FROM cpcALL WHERE cpc_continuo > ? AND (id_centro IS NULL OR id_centro != ?) AND id_area == ? AND ano == ? AND publico == 1 AND UF == 'RS') as i6", valores: [cpc.CPCSimulado as AnyObject, curso.idCentro as AnyObject, curso.idArea as AnyObject, curso.ano as AnyObject])
        
        while(rs.next()){
            posicao.pos_pub_rs = Int.init(rs.int(forColumn: "RS_PUB")) + 1
        }
        database.fecharDatabase()
        
        return posicao
    }
    
    class func getListaInstituicoes(_ cpc:CPC, tipo:Int) -> [Instituicao] {
        var inst:Array<Instituicao> = []
        let database:SQLiteHelper = SQLiteHelper(database: "cpc")
        var sql:String = "SELECT cpc_continuo, municipio, sigla_ies, id_municipio, id_ies, id_centro FROM cpcALL WHERE cpc_continuo > ? AND (id_centro IS NULL OR id_centro != ?) AND id_area == ? AND ano == ?"
        
        switch (tipo) {
            case 1:
                sql+=" AND regiao == 1 "
                break
            case 2:
                sql+=" AND UF == 'RS' "
                break
            case 3:
                sql+=" AND publico == 1 "
                break
            case 4:
                sql+=" AND regiao == 1 AND publico == 1 "
                break
            case 5:
                sql+=" AND UF == 'RS' AND publico == 1 "
                break
            default:
                break
        }
        sql+=" ORDER BY cpc_continuo DESC"
        
        database.abrirDatabase()
        let rs:FMResultSet = database.executarQuery(sql, valores: [cpc.CPCSimulado as AnyObject, cpc.idCentro as AnyObject, cpc.idArea as AnyObject, cpc.ano as AnyObject])
        
        while(rs.next()){
            let i:Instituicao = Instituicao()
            i.ano = cpc.ano
            i.idArea = cpc.idArea
            i.CPCContinuo = rs.double(forColumn: "cpc_continuo")
            i.municipio = rs.string(forColumn: "municipio")
            
            if(rs.columnIsNull("sigla_ies")){
                i.siglaIes = i.municipio
            }else{
                i.siglaIes = rs.string(forColumn: "sigla_ies")
            }
            
            i.idMunicipio = Int.init(rs.int(forColumn: "id_municipio"))
            i.idIes = Int.init(rs.int(forColumn: "id_ies"))
            i.idCentro = Int.init(rs.int(forColumn: "id_centro"))
            
            inst.append(i)
        }
        database.fecharDatabase()
        
        return inst
    }
    
    class func getCPCInstituicao(inst:Instituicao) -> CPC {
        let cpc:CPC = CPC()
        let database:SQLiteHelper = SQLiteHelper(database: "cpc")
        
        database.abrirDatabase()
        let rs:FMResultSet = database.executarQuery("SELECT Nota_Continua_Enade, Nota_Padronizada_IDD, Nota_Padronizada_Infraestrutura, Nota_Padronizada_Organ_Did_Pedag, Nota_Padronizada_Oport_Amplia, Nota_Padronizada_Doutores, Nota_Padronizada_Mestres, Nota_Padronizada_Regime_Trabalho FROM CpcAll WHERE id_ies == ? AND CpcAll.ano == ? AND CpcAll.id_area == ?", valores: [inst.idIes as AnyObject, inst.ano as AnyObject, inst.idArea as AnyObject])
        
        while(rs.next()){
            cpc.ano = inst.ano
            cpc.CPCContinuo = 0.0
            cpc.CPCF2013 = 0.0
            cpc.CPCSimulado = 0.0
            cpc.notaPadronizadaEnade = rs.double(forColumn: "Nota_Continua_Enade")
            cpc.notaPadronizadaIdd = rs.double(forColumn: "Nota_Padronizada_IDD")
            cpc.notaPadronizadaInfraestrutura = rs.double(forColumn: "Nota_Padronizada_Infraestrutura")
            cpc.notaPadronizadaOrgDidaticaPedag = rs.double(forColumn: "Nota_Padronizada_Organ_Did_Pedag")
            cpc.notaPadronizadaOportunidadeAmp = rs.double(forColumn: "Nota_Padronizada_Oport_Amplia")
            cpc.notaPadronizadaDoutores = rs.double(forColumn: "Nota_Padronizada_Doutores")
            cpc.notaPadronizadaMestres = rs.double(forColumn: "Nota_Padronizada_Mestres")
            cpc.notaPadronizadaRegTrabalho = rs.double(forColumn: "Nota_Padronizada_Regime_Trabalho")
        }
        database.fecharDatabase()
        
        return cpc
    }
    
}
