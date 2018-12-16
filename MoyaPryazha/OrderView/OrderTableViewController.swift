//
//  OrderTableViewController.swift
//  MoyaPryazha
//
//  Created by Dennis Zubkoff on 21/11/2018.
//  Copyright © 2018 Dennis Zubkoff. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class OrderTableViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

    let titleLabel = UILabel()
    var orderSum: Int = 0
    let globalSettings = GlobalSettings()
    let coreDataStack = CoreDataStack()
    var context: NSManagedObjectContext!
    let rootViewController = AppDelegate.shared.rootViewController
    
    
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var deliverySegmentControl: UISegmentedControl!
    @IBOutlet weak var paymentSegmentControl: UISegmentedControl!
    @IBOutlet weak var addAddressButton: UIButton!
    @IBOutlet weak var deliveryLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        context = coreDataStack.persistentContainer.viewContext
        
        guard let statusBarView = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            else { return }
        statusBarView.backgroundColor = #colorLiteral(red: 0.4044061303, green: 0.6880503297, blue: 0.001034987159, alpha: 1)
        
        nameTextField.delegate = self
        phoneTextField.delegate = self
        emailTextField.delegate = self
        
       
        
        tabBarController?.tabBar.tintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        titleLabel.font = UIFont(name: "AaarghCyrillicBold", size: 17)
        titleLabel.text = "Заказ: \(orderSum) руб"
        titleLabel.textColor = UIColor.white
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        titleLabel.minimumScaleFactor = 0.75 // Минимальный относительный размер шрифта
        navigationItem.titleView = titleLabel
        deliverySegmentControl.selectedSegmentIndex = 2
        orderButton.layer.cornerRadius = 5
        addAddressButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let _ = rootViewController.loadUserFromCoreData(context: context)
        let _ = rootViewController.loadUserAddressFromCoreData(context: context)
        nameTextField.text = rootViewController.user?.name
        emailTextField.text = rootViewController.user?.email
        phoneTextField.text = rootViewController.user?.phone
        let _ = rootViewController.loadUserAddressFromCoreData(context: context)
        addressTextView.text = rootViewController.userAddresses.first?.address
        deliverySegmentControl.selectedSegmentIndex = Int(rootViewController.user?.delivery ?? 2)
        paymentSegmentControl.selectedSegmentIndex = Int(rootViewController.user?.payment ?? 1)
        navigationItem.rightBarButtonItem?.isEnabled = checkOrderData()
        orderButton.isEnabled = checkOrderData()
        tableView.reloadData()
        updateStatePayment()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let _ = saveUserDataToCoreData()
    }
    
    
    @IBAction func saveAddress(unwindSegue: UIStoryboardSegue) {
        let dvc = unwindSegue.source as! AddressViewController
        let _ = rootViewController.appendToUserAddresses(user: rootViewController.user, address: dvc.addressString)
        addressTextView.text = dvc.addressString
    }
    @IBAction func sendOrderButton(_ sender: UIButton) {
        prepareOrder()
    }
    
    @IBAction func orderConfirmedBarButtonItem(_ sender: UIBarButtonItem) {
        
        prepareOrder()
    }
    
    func prepareOrder() {
        
        let _ = saveUserDataToCoreData()
        //sendOrder()
        let message = sendOrderViaSite()
        if message.count != -1 {
            for basket in rootViewController.baskets {
                let _ = rootViewController.putProductToBasket(product: basket.product, quantity: 0)
            }
            tabBarController?.tabBar.items?[2].badgeValue = "\(rootViewController.sumBasket())"
            do {
                try context.save()
            } catch let error as NSError {
                print(error)
            }
            
        }
        let alertData = UIAlertController(title:"Обработка заказа", message: message.error, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Ok", style: .default, handler:{
            (_) in
            self.performSegue(withIdentifier: "returnToBasketSegue", sender: self)
        })
        
        alertData.addAction(cancelAction)
        present(alertData, animated: true, completion: nil)
    }
    
    func sendOrder() {
        let mailComposeViewController = MFMailComposeViewController()
        mailComposeViewController.mailComposeDelegate = self
        mailComposeViewController.setToRecipients([globalSettings.moyaPryazhaEmail, emailTextField.text ?? "denzu@mac.com"])
        mailComposeViewController.setSubject("Заказ из приложения от \(nameTextField.text ?? "Неизвестный")")
        mailComposeViewController.setMessageBody(getOrderMailBody(), isHTML: true)
        if MFMailComposeViewController.canSendMail() {
            present(mailComposeViewController, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
    }
    
    func sendOrderViaSite() -> ReturnResult {
        var returnResiult = saveUserDataToCoreData()
        guard returnResiult.count != -1 else { return returnResiult }
        guard let url = URL(string: "https://moya-pryazha.ru/services/srvSendMail.php")
            else {
                returnResiult.count = -1
                returnResiult.error = "Сервис отправки заказа не доступен. Попробуйте позже..."
                return returnResiult
        }
        var emailSended = 0
        guard let name = rootViewController.user?.name
            else {
                returnResiult.count = -1
                returnResiult.error = "Заполните Фамилию, Имя, Отчество!"
                return returnResiult
        }
        guard let email = rootViewController.user?.email
            else {
                returnResiult.count = -1
                returnResiult.error = "Заполните Email!"
                return returnResiult
        }
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let dateString = dateFormatter.string(from: date)
        let parameters = ["email": "\(name) <\(email)>",
            "from": "Приложение Моя Пряжа <\(globalSettings.moyaPryazhaEmail)>",
            "subject": "Заказ от \(dateString) на сумму \(orderSum) руб",
            "body": getOrderMailBody()]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            returnResiult.count = -1
            returnResiult.error = "Нет возможности отправить заказ. Попробуйте позже..."
            return returnResiult
        }
        request.httpBody = httpBody
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    if let postData = data,
                        let postString = String(data: postData, encoding: String.Encoding.utf8) {
                        if postString == "OK" {
                            emailSended = 1
                        }
                    }
                }
            }
            if emailSended != 1 {
                emailSended = -1
            }
            
        }
        task.resume()
        while emailSended == 0 {
            if emailSended == -1 {
                returnResiult.count = -1
                returnResiult.error = "Сервис отправки заказа не доступен. Попробуйте позже..."
            } else if emailSended == 1 {
                returnResiult.count = 0
                returnResiult.error = "Спасибо за заказ!\nВаш заказ получен.\nВ ближайшее время наш менеджер свяжется с Вами."
            }
        }
        return returnResiult
    }
    

    
    func getOrderMailBody() -> String {
        let user = rootViewController.user
        let baskets = rootViewController.baskets
        var body: String = ""
        body = "<p>Уважаемая(ый) \(user?.name ?? "")!</p>"
        body += "<p>Вы сделали заказ в мобильном приложении Моя Пряжа на сумму  \(orderSum) рублей. Ваш заказ получен!</p>"
        
        body += "<p>Параметры заказа:</p>"
        body += "<p>ФИО: \(user?.name ?? "Не указан")<br>"
        body += "Тел: \(user?.phone ?? "Не указан")<br>"
        body += "Email: \(user?.email ?? "Не указан")</p>"
        
        let delivery = Int(user?.delivery ?? 0)
        let deliveryName = deliverySegmentControl.titleForSegment(at: delivery) ?? "Не указана"
        body += "<p>Доставка: \(deliveryName)<br>"
        if delivery == 2 {
            body += "Адрес: \(globalSettings.moyaPryazhaAddress)</p>"
        } else {
            body += "Адрес: \(rootViewController.userAddresses.first?.address ?? "Не указан")</p>"
        }
        
        let payment = Int(user?.payment ?? 0)
        let paymentName = paymentSegmentControl.titleForSegment(at: payment) ?? "Не указан"
        body += "<p>Оплата: \(paymentName)</p>"
        
        body += "<style> table {border: 1px solid grey;} th {border: 1px solid grey;} td {border: 1px solid grey;}  </style>\n"
        body += "<table>\n"
        body += "<style> table {border: 1px solid grey;} </style>\n"
        body += "<tfoot>"
        body += "<tr>"
        body += "<td colspan=\"4\" style=\"text-align:right\">ИТОГО:</td><td style=\"text-align:right\">\(orderSum)</td>"
        body += "</tr>"
        body += "</tfoot>"
        body += "<caption>Содержимое заказа</caption>"
        body += "<tr>"
        body += "<th>№№</th>"
        body += "<th>Наименование товара</th>"
        body += "<th>Количество</th>"
        body += "<th>Цена, руб.</th>"
        body += "<th>Стоимость, руб.</th>"
        body += "</tr>"
        var i: Int = 0
        for basket in baskets {
            i += 1
            let price = Int(rootViewController.prices.filter({$0.product == basket.product && $0.priceType?.id ?? 1 == 1}).first?.price ?? 0)
            body += "<tr>"
            body += "<td style=\"text-align:right\">\(i)</td>"
            body += "<td>\(basket.product?.name ?? "Не указан")</td>"
            body += "<td style=\"text-align:right\">\(basket.quantity)</td>"
            body += "<td style=\"text-align:right\">\(price)</td>"
            body += "<td style=\"text-align:right\">\(price * Int(basket.quantity))</td>"
            body += "</tr>"
        }
        body += "</table>"
        
        body += "<p>Спасибо за заказ! В ближайщее время наш менеджер свяжется с Вами.</p>"
        body += "<p>С уважением,<br> <a href=\"https://www.moya-pryazha.ru\">Интернет-магазин Моя Пряжа</a>.</p>"
        
        return body
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func textFieldChanged(_ sender: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = checkOrderData()
        orderButton.isEnabled = checkOrderData()
    }
    
    @IBAction func changedDeliverySegmentControl(_ sender: UISegmentedControl) {
        updateStatePayment()
    }
    
    func updateStatePayment() {
        if deliverySegmentControl.selectedSegmentIndex != 2 {
            paymentSegmentControl.selectedSegmentIndex = 0
            paymentSegmentControl.isEnabled = false
            addressTextView.text = rootViewController.userAddresses.first?.address ?? ""
            addAddressButton.isEnabled = true
            deliveryLabel.text = "Адрес доставки:"
        } else {
            paymentSegmentControl.isEnabled = true
            addressTextView.text = globalSettings.moyaPryazhaAddress
            addAddressButton.isEnabled = false
            deliveryLabel.text = "Адрес самовывоза:"
        }
    }
    
    func checkOrderData() -> Bool {
        guard !addressTextView.text.isEmpty else { return false }
        guard !(nameTextField.text?.isEmpty ?? true) else { return false }
        guard !(phoneTextField.text?.isEmpty ?? true) else { return false }
        guard !(emailTextField.text?.isEmpty ?? true) else { return false }
        return true
    }
    
    func saveUserDataToCoreData() -> ReturnResult {
        var returnResult = rootViewController.updateUser(name: nameTextField.text ?? "", phone: phoneTextField.text ?? "", email: emailTextField.text ?? "", delivery: deliverySegmentControl.selectedSegmentIndex, payment: paymentSegmentControl.selectedSegmentIndex)
        if deliverySegmentControl.selectedSegmentIndex != 2 {
            returnResult = rootViewController.appendToUserAddresses(user: rootViewController.user, address: addressTextView.text)
        }
        do {
            try context.save()
            return returnResult
        } catch let error as NSError {
            returnResult.error = "Ошибка сохранения данных пользователя: \(error.localizedDescription)"
            returnResult.count = -1
            print(returnResult.error)
            return returnResult
        }
    }
    
}
