#!/usr/bin/env python3

"""
#   Script de bkp - T6
#   PSO 2016/2
#   Mauricio D. e Brenda S.
#   Conta Dropbox para testes:
#       email: tehevox@stromox.com
#       senha: 123qwe
#       app_key: zcw2xtt1r03rnm3
#       app_secret: zammnfe825dgexu
"""

import os
import sys
import hashlib
import time
import sqlite3
import dropbox
import sqlite3

############################################################
# Funcao responsavel por criar a base de dados quando o
# script for executado pela primeira vez
############################################################
def criar_database():
    conexao = sqlite3.connect("bkp.db")

    cursor = conexao.cursor()
    cursor.execute('''CREATE TABLE log (data text, arquivo text, hash text, acesso text)''')

    conexao.close()

################################################################
# Funcao com objetivo de listar todos os arquivo/diretorios
# presentes no dir_bkp
################################################################
def listar_arquivos(path):
    arquivos = []
    diretorios = []
    full_path = []
    hash = hashlib.md5()

    for root, dirs, files in os.walk(path):
        diretorios.append('/' + str(root) + '/')
        for f in files:
            if str(f) != ".DS_Store":
                file = open(os.path.join(os.path.abspath(root), f), 'rb')
                leitura = file.read()
                hash.update(leitura)
                ultimo_acesso = os.path.getmtime(os.path.join(os.path.abspath(root), f))
                arquivos.append(os.path.basename(f))
                full_path.append((str(root) + '/' + os.path.basename(f), hash.hexdigest(), ultimo_acesso))

    return arquivos, diretorios, full_path

####################################################################
# Funcao responsavel por autenticar um usuario (de desenvolvimento)
# na aplicacao. Retorna um token de acesso
####################################################################
def solicitar_dropbox():
    app_key = 'zcw2xtt1r03rnm3'
    app_secret = 'zammnfe825dgexu'

    flow = dropbox.client.DropboxOAuth2FlowNoRedirect(app_key, app_secret)
    authorize_url = flow.start()

    print('1. Va em: ' + authorize_url)
    print('2. Click "Allow" / "Permitir" (voce deve estar logado em sua conta dropbox)')
    print('3. Copie o codigo de autorizacao')
    code = input("Informe aqui seu codigo de autorizacao: ").strip()

    access_token, user_id = flow.finish(code)
    client = dropbox.client.DropboxClient(access_token)
    return client

####################################################################
# Funcao responsavel por listar todos os arquivos e diretorios que
# estao presentes na conta Dropbox informada
# Codigo baseado em Efficiently enumerating Dropbox with /delta
# by Steve Marx
####################################################################
def listar_arquivos_dropbox(usuario_dropbox, files=None, cursor=None):
    lista = []
    if files is None:
        files = {}

    has_more = True

    while has_more:
        result = usuario_dropbox.delta()
        cursor = result['cursor']
        has_more = result['has_more']

        for lowercase_path, metadata in result['entries']:
            if metadata is not None:
                files[lowercase_path] = metadata
            else:
                files.pop(lowercase_path, None)

    # in case this was a directory, delete everything under it
    for other in files.keys():
        if other.startswith(lowercase_path + '/'):
            del files[other]

    for k in files:
        if not files[k]['is_dir']:
            lista.append(files[k]['path'])

    return lista

##############################################################
# Funcao que retorna a lista dos arquivos (arquivos e hash)
# realizados na ultima sincronizacao
##############################################################
def arquivos_log_mais_recente():
    arquivos = []
    conexao = sqlite3.connect("bkp.db")
    c = conexao.cursor()

    max_data = ""
    for row in c.execute('SELECT max(data)  FROM log'):
        max_data = row[0]

    for row in c.execute('SELECT arquivo, hash, acesso FROM log WHERE data = "' + str(max_data) + '"'):
        arquivos.append((str(row[0]), str(row[1]), str(row[2])))

    conexao.close()
    return arquivos

########################################################
# Funcao responsavel por inserir no bd as informacoes
# sobre o ultimo upload
########################################################
def inserir_log_database(arquivo):
    conexao = sqlite3.connect("bkp.db")
    c = conexao.cursor()

    data = str(time.strftime("%d/%m/%Y"))
    file = arquivo[0]
    hash = arquivo[1]
    acesso = arquivo[2]
    #print(' INSERT INTO log VALUES("' + str(data) + '","' +  str(file) +  '","' + str(hash) + '")  ')
    c.execute('INSERT INTO log VALUES("' + str(data) + '","' +  str(file) +  '","' + str(hash) +  '","'+ str(acesso) +'")')

    conexao.commit()
    conexao.close()

########################################################
# Funcao responsavel por alterar a hash do arquivo no
# bd
########################################################
def alterar_log_database(arquivo):
    conexao = sqlite3.connect("bkp.db")
    c = conexao.cursor()

    data = str(time.strftime("%d/%m/%Y"))
    file = arquivo[0]
    hash = arquivo[1]
    acesso = arquivo[2]

    c.execute( ' UPDATE log SET hash = "' + hash + '", acesso = "' + str(acesso) +'" WHERE data = "' + data + '" AND arquivo = "' + file + '"' )

    conexao.commit()
    conexao.close()

################################################################
# Funcao com objetivo de listar verificar quais arquivos estao
# presentes no dir_bkp mas nao estao no dropbox
################################################################
def verificar_diferenca_arquivos(local, dropbox):
    dif = []
    alterados = []

    # Verifica quais arquivos nao estao no dropbox
    for f in local:
        nf = f[0]
        if nf[0] == '/':
            if nf not in dropbox:
                dif.append(f)
        else:
            if str('/' + nf) not in dropbox:
                dif.append(f)


    # Verifica quais arquivos foram alterados
    # Desde o ultimo upload
    arquivos_log = arquivos_log_mais_recente()
    for i in range(len(local)):
        for j in range(len(arquivos_log)):
            if str(local[i][0]) == str(arquivos_log[j][0]) and str(local[i][1]) != str(arquivos_log[j][1]) and str(local[i][2]) != str(arquivos_log[j][2]):
                alterados.append(local[i])

    return dif, alterados

######################################################
# Funcao que verifica se a data atual eh a mesma
# data do ultimo log no bd
######################################################
def is_data_log_atualizado():
    conexao = sqlite3.connect("bkp.db")
    c = conexao.cursor()
    data_atual = str(time.strftime("%d/%m/%Y"))
    max_data = ""

    for row in c.execute('SELECT max(data)  FROM log'):
        max_data = row[0]

    conexao.close()

    if str(max_data) == data_atual:
        return True
    else:
        return False

####################################################################
# Funcao responsavel por realizar o upload dos arquivos diferentes
# (adicionados ou modificados)
####################################################################
def upload_arquivos(usuario_dropbox, arquivos, arquivos_alterados):
    data_atualizada = is_data_log_atualizado()

    for f in arquivos:
        print("Uploading: " + str(f[0]))
        if data_atualizada:
            inserir_log_database(f)
        nome_arquivo = str(f[0])
        f_open = open(os.path.abspath(nome_arquivo), 'rb')
        usuario_dropbox.put_file(nome_arquivo, f_open)

    for f in arquivos_alterados:
        print("Alterando: " + str(f[0]))
        if data_atualizada:
            alterar_log_database(f)
        nome_arquivo = str(f[0])
        usuario_dropbox.file_delete(nome_arquivo)
        f_open = open(os.path.abspath(nome_arquivo), 'rb')
        usuario_dropbox.put_file(nome_arquivo, f_open)

    if not is_data_log_atualizado():
        for f in arquivos_full_path:
            inserir_log_database(f)

###################################################
# Funcao responvel por realizar o donwload dos
# arquivos armazenados no log
###################################################
def donwload_arquivos(usuario_dropbox, listar_arquivos):
    for arq in listar_arquivos:
        print("Downloading: " + str(arq))
        lista_path = str(arq).split('/')
        lista_path = lista_path[:len(lista_path)-1]
        d = '/'.join(lista_path)

        if not os.path.exists(os.path.abspath(d)):
            print("Criando " + os.path.abspath(d))
            os.mkdir(os.path.abspath(d))
        out = open(arq, 'wb')
        with usuario_dropbox.get_file(arq) as f:
            out.write(f.read())
        out.close()

################################################
# Funcao que exibe o menu principal do programa
################################################
def exibir_menu_principal():
    print("Escolha uma Opcao:")
    print("\t1) Sincronizar arquivos")
    print("\t2) Visualizar log")
    print("\t3) Sair do programa")

##############################################
# Funcao responvel por listar todas as datas
# presentes no log
##############################################
def listar_datas_log():
    conexao = sqlite3.connect("bkp.db")
    c = conexao.cursor()
    data = []

    for row in c.execute('SELECT distinct(data) FROM log'):
        data.append(row[0])

    conexao.close()

    return data

#################################################
# Funcao responsavel por listar os arquivos de
# um determinada data recebida por parametro
#################################################
def listar_arquivos_data_log(data):
    conexao = sqlite3.connect("bkp.db")
    c = conexao.cursor()
    arquivos = []

    for row in c.execute('SELECT arquivo FROM log WHERE data = "' + str(data) + '"'):
        arquivos.append(row[0])

    conexao.close()

    return arquivos

############## Main ##############

# Testa se foi passado algum parametro pro Script
dir_bkp = ""
if(len(sys.argv) < 2):
    print("Execucao: ./t6-mdonato-bsantana [dir_bkp]")
    exit()
else:
    # Verifica se possui / no final do diretorio
    # Se exister, remove
    if(str(sys.argv[1])[len(sys.argv[1])-1] == '/'):
        dir_bkp = str(sys.argv[1])[:len(sys.argv[1])-1]
    else:
        dir_bkp = str(sys.argv[1])

# Verifica se o diretorio passado como parametro efetivamente existe
if(os.path.exists(dir_bkp)):
    print("Diretorio encontrado!")

    # Verifica se existe o banco de dados
    if(not os.path.exists("bkp.db")):
        print("Criando base de dados...")
        criar_database()

    print("Iniciando acesso ao Dropbox...")
    usuario_dropbox = solicitar_dropbox()
    print("Dropbox acessado com sucesso!")

    while True:
        exibir_menu_principal()
        resp = int(input("Escolha uma opcao: "))

        if resp == 1:
            print("Construindo arvore de diretorio/arquivo...")
            arquivos_local, diretorios_local, arquivos_full_path = listar_arquivos(dir_bkp)

            print("Obtendo diretorios/arquivos do Dropbox...")
            arquivos_dropbox = listar_arquivos_dropbox(usuario_dropbox)

            print("Verificando diferenca entre pasta local e dropbox...")
            arquivos_upload, arquivos_alterados = verificar_diferenca_arquivos(arquivos_full_path, arquivos_dropbox)

            if len(arquivos_upload) > 0 or len(arquivos_alterados) > 0:
                print("Iniciando upload...")
                upload_arquivos(usuario_dropbox, arquivos_upload, arquivos_alterados)
                print("Upload realizado com sucesso!")
            else:
                print("Todos arquivos estao atualizados!")

        elif resp == 2:
            datas_log = listar_datas_log()

            if len(datas_log) > 0:
                print("Datas encontradas: ")
                print("Selecione o indice da data para Visualizar os arquivos!")
                
                for i in range(len(datas_log)):
                    print("\t" + str(i) + ") " + datas_log[i])

                data_escolhida = int(input("Informe o indice da data: "))
                if data_escolhida >= len(datas_log):
                    print("Indice invalido!")
                else:
                    print("Arquivos encontrados: ")
                    arquivos_log_data = listar_arquivos_data_log(datas_log[data_escolhida])
                    for f in arquivos_log_data:
                        print("\t" + f)

                    op = input("Deseja fazer o download desses arquivo? [S/N]: ")
                    if op == 'S' or op == 's':
                        donwload_arquivos(usuario_dropbox, arquivos_log_data)
            else:
                print("Nenhuma log encontrado!")

        elif resp == 3:
            exit()

        else:
            print("Opcao Invalida!")
else:
    print("Diretorio nao encontrado!")
    exit()
