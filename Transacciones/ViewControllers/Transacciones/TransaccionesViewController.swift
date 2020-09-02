//
//  TransaccionesViewController.swift
//  Transacciones
//
//  Created by Andres Marin on 25/08/20.
//  Copyright © 2020 Andres Marin. All rights reserved.
//

import UIKit
import Alamofire
import HandyJSON
import FSnapChatLoading

class TransaccionesViewController: UITableViewController {
    
    var Transaciones : [JsonTransacciones?]?
    
    let loadingView = FSnapChatLoadingView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        cargarTransaciones()
    }
    
    
    // MARK: - Funciones
    
    private func cargarTransaciones() {
        
        loadingView.show(view: self.navigationController?.view, color: UIColor.yellow)

        AF.request(Leal.baseURL + Endpoint.transactions, method: .get, encoding: JSONEncoding.default).responseString { response in

            switch response.result {
               case .success(let value) :
                
                self.loadingView.hide()


                if let json = [JsonTransacciones].deserialize(from: value) {
                    
                    self.Transaciones = json
                    
                    self.tableView.reloadData(efecto: .Roll)
                }
                
               case .failure(let error) :
                   let error = error as Error
                   print(error.localizedDescription)
               }
        }
        
    }
    
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let trans = self.Transaciones {
            return trans.count
        } else {
            return 0
        }
    }

      
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CellTransacciones") as! CellTransacciones
          
          if let trans = self.Transaciones {

            cell.lblId.text = "Transaccion # \(trans[indexPath.row]?.id ?? 0)"
            
            // Ponemos el view en circulo
            cell.viewEstado.layer.cornerRadius = cell.viewEstado.frame.size.width/2;
            
            cell.viewEstado.backgroundColor = trans[indexPath.row]?.colorEstado
            cell.viewEstado.isHidden = indexPath.row >= 20
            
          }
          
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let trans = self.Transaciones {
            trans[indexPath.row]?.colorEstado = UIColor.gray
            tableView.reloadRows(at: [indexPath], with: .fade)
                        
            performSegue(withIdentifier: "DetalleSegue", sender: trans[indexPath.row])
        }
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            if var trans = self.Transaciones {
                trans.remove(at: indexPath.row)
                self.Transaciones = trans
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection
//                                section: Int) -> String? {
//       return "Transactions"
//    }
    
    
    // MARK: - IBAction de botones
    
    @IBAction func butRecargar(_ sender: UIBarButtonItem) {
        cargarTransaciones()
    }
    
    @IBAction func butEliminarTodo(_ sender: Any) {

        if var trans = self.Transaciones {
            for _ in trans {
                
                let indexPath = IndexPath.init(row: 0, section: 0)
                
                trans.remove(at: indexPath.row)
                self.Transaciones = trans
                
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    
    // MARK: - Prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    
        if segue.identifier == "DetalleSegue" {
            
            let detalleViewController = segue.destination as! DetalleTransaccionViewController
            
            //Enviamos la transaccion seleccionada
            if let trasn = sender as? JsonTransacciones {
                detalleViewController.transaccion = trasn
            }
            
        }
            
    }
}



