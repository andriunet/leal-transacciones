//
//  DetalleTransaccionViewController.swift
//  Transacciones
//
//  Created by Andres Marin on 26/08/20.
//  Copyright © 2020 Andres Marin. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DetalleTransaccionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var lblNombreUsuario: UILabel!
    @IBOutlet weak var imageViewUsuario: LoadingImageView!
    @IBOutlet weak var lblNombreCommerce: UILabel!
    @IBOutlet weak var lblNombreSucursal: UILabel!

    @IBOutlet weak var lblPuntos: UILabel!
    @IBOutlet weak var lblValor: UILabel!
   
    
    @IBOutlet weak var lblValueToPoints: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var transaccion: JsonTransacciones?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
            
        cargarUsuario()
        cargarTransaccionInfo()        
        
        if let trans = transaccion {
            lblNombreCommerce.text = trans.commerce?.name!
            lblValueToPoints.text = "\(trans.commerce?.valueToPoints ?? 0)"
            lblNombreSucursal.text = trans.branch?.name!

            self.title = "\(trans.id ?? 0)"
        }
        
        tableView.reloadData(efecto: .Roll)
    }
    
    // MARK: - Funciones
    
    func cargarUsuario() {
        
         if let trans = transaccion {
            
            AF.request(Leal.baseURL + Endpoint.users + "\(trans.userId ?? 0)", method: .get, encoding: JSONEncoding.default).responseString { response in

                switch response.result {
                   case .success(let value) :
                    
                    if let jsonUsuario = JsonUsuarios.deserialize(from: value) {
                                                
                        self.lblNombreUsuario.text = jsonUsuario.name!
                        
                        //Cargamos la foto
                        if let foto = jsonUsuario.photo {
                            _ = self.imageViewUsuario.downloadImage(URL(string: foto)!, placeholder: nil)                            
                        }
                    }
                    
                   case .failure(let error) :
                       let error = error as Error
                       print(error.localizedDescription)
                   }
            }
        }
        
    }
    
    func cargarTransaccionInfo() {
        
         if let trans = transaccion {
            
            AF.request(Leal.baseURL + Endpoint.transactions + "\(trans.id ?? 0)" + Endpoint.transactionInfo, method: .get, encoding: JSONEncoding.default).responseString { response in

                switch response.result {
                   case .success(let value) :
                    
                    if let jsonTransaccionInfo = JsonTransaccionInfo.deserialize(from: value) {
                                                
                        self.lblPuntos.text = "\(jsonTransaccionInfo.points ?? 0)"
                        self.lblValor.text = "\(jsonTransaccionInfo.value ?? 0)"
                    }
                    
                   case .failure(let error) :
                       let error = error as Error
                       print(error.localizedDescription)
                   }
            }
        }
        
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let branch = self.transaccion?.commerce?.branches {
            return branch.count
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellBranches")
          
        if let branch = self.transaccion?.commerce?.branches {

            cell?.textLabel?.text = "\(branch[indexPath.row].id ?? 0)"
            cell?.detailTextLabel?.text = branch[indexPath.row].name
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
       return "Branches"
    }
    
}
