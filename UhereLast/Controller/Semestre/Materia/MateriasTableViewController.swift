//
//  MateriasTableViewController.swift
//  UHere_Prototype
//
//  Created by Wellington Tatsunori Asahide on 03/11/18.
//  Copyright © 2018 tatsu. All rights reserved.
//

import UIKit

class MateriasTableViewController: TableViewController {
    var semestre: Semestre?
    var ids: [String] = []
    var dias: [Bool] = []
    var horas: [Date] = []
    var mediaAtual: Double = 0
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return semestre?.materias?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "materiaCell", for: indexPath) as! MateriaCell
        
        if let materia = semestre?.materias?[indexPath.row] {
            cell.lbNome.text = materia.nome
            cell.viewColor.backgroundColor = UIColor.colorWithHexString(materia.cor!)
            
            cell.lbFaltas.text = String(materia.faltas)
            if let faltas = materia.falta?.count{
                cell.lbLimiteFaltas.text = String(faltas) + "/" + String(materia.limiteFalta)
            }
            
            cell.lbLocal.text = materia.local
            cell.lbAvaliacoes.text = String(materia.provas?.count ?? 0)
            cell.lbMedia.text = materia.getMedia() // String(mediaAtual)
            cell.lbSituacao.text = materia.getSituation() //calculoSituacao(provas: materia.provas!)            
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "novaMateriaTableViewController"){
            guard let destination = segue.destination as? NovaMateriaTableViewController else {
                return 
            }
            destination.semestre = semestre
        }
        if (segue.identifier == "exibeMateria"){
            guard let destination = segue.destination as? ExibeMateriaTableViewController else {
                return
            }
            destination.materia = (semestre?.materias?[(tableView.indexPathForSelectedRow?.row)!])!
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Deletar"){ (contextualAction, view, actionPerformed:@escaping (Bool) -> ()) in
            
            let alerta = UIAlertController(title: "DELETAR DISCIPLINA", message: "A disciplina "+(self.semestre?.materias?[indexPath.row].nome)!+" está sendo deletada, você tem certeza deseja prosseguir ?", preferredStyle: .actionSheet)
            
            alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: {(alertAction) in
                actionPerformed(false)
            }))
            
            alerta.addAction(UIAlertAction(title: "Deletar", style: .default, handler: {(alertAction) in
                let materiaDeletar = self.semestre?.materias![indexPath.row]
                
                self.deleteIds(materia: materiaDeletar!)
                
                Materia.delete(materia: (self.semestre?.materias?[indexPath.row])!)
                tableView.deleteRows(at: [indexPath], with: .fade)
                actionPerformed(true)
            }))
            
            self.present(alerta, animated: true, completion: nil)
        }
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteIds(materia: Materia){
        loadDatas(materia: materia)
        for i in 0...dias.count - 1{
            if (dias[i]){
                ids.append(Notificacoes.idGeneratorForMateria(type: Controller.Tipos.Aula.tipo(), materia: materia.nome!, weekday: String(i)))
            }
        }
        
        let provas = materia.provas
        for provaADeletar in provas!{
            let id = Notificacoes.idGenerator(type: "Avaliacoes", materia: provaADeletar.materia!.nome!, title: provaADeletar.nome!, date: provaADeletar.diaHora! as Date)
            ids.append(id)
        }
        
        let atividades = materia.atividades
        for atividade in atividades!{
            let id: String!
            if (atividade.relationship != nil){
                id = Notificacoes.idGenerator(type: "Atividade",materia: atividade.relationship!.nome!, title: atividade.nome!, date: atividade.diaHora! as Date)
            }else{
                id = Notificacoes.idGenerator(type: "Atividade",materia: "Indefinido", title: atividade.nome!, date: atividade.diaHora! as Date)
            }
            
            ids.append(id)
        }
        
        Notificacoes.delete(id: self.ids)
        self.ids = []
        dias = []
        horas = []
    }
    
    func loadDatas(materia: Materia){
        let diasHoras = materia.diasHoras!
        dias = Controller.getDiasSemana(diasHoras: diasHoras)
        horas.append(diasHoras.hDomingo! as Date)
        horas.append(diasHoras.hSegunda! as Date)
        horas.append(diasHoras.hTerca! as Date)
        horas.append(diasHoras.hQuarta! as Date)
        horas.append(diasHoras.hQuinta! as Date)
        horas.append(diasHoras.hSexta! as Date)
        horas.append(diasHoras.hSabado! as Date)
    }

}
