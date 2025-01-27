//
//  MessageTableViewCell.swift
//  Bark
//
//  Created by huangfeng on 2020/5/26.
//  Copyright © 2020 Fin. All rights reserved.
//

import Material
import RxSwift
import UIKit

class MessageTableViewCell: BaseTableViewCell<MessageTableViewCellViewModel> {
    let backgroundPanel: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.clipsToBounds = true
        view.backgroundColor = BKColor.background.secondary
        return view
    }()
    
    let bodyLabel: UITextView = {
        let label = UITextView()
        label.isEditable = false
        label.dataDetectorTypes = [.phoneNumber, .link]
        label.isScrollEnabled = false
        label.textContainerInset = .zero
        label.textContainer.lineFragmentPadding = 0
        label.font = RobotoFont.regular(with: 14)
        label.textColor = BKColor.grey.darken4
        return label
    }()
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = RobotoFont.medium(with: 11)
        label.textColor = BKColor.grey.base
        return label
    }()

    let separatorLine: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = BKColor.background.primary
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        
        self.backgroundColor = BKColor.background.primary
        contentView.addSubview(backgroundPanel)
        contentView.addSubview(bodyLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(separatorLine)

        layoutView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tap))
        tap.name = "messageTap"
        tap.delegate = self
        bodyLabel.addGestureRecognizer(tap)
    }
    
    @objc func tap() {
        var view = self.superview
        while view != nil, (view as? UITableView) == nil {
            view = view?.superview
        }
        guard let tableView = view as? UITableView else {
            return
        }
        
        guard let indexPath = tableView.indexPath(for: self) else {
            return
        }
        tableView.delegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    // 单击手势如果没点击链接，则传递给UITableView didSelectRow
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.name == "messageTap", otherGestureRecognizer.name == "UITextInteractionNameLinkTap" {
            return true
        }
        return false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layoutView() {

        bodyLabel.snp.remakeConstraints { make in
            make.top.equalTo(16)
            make.left.equalTo(28)
            make.right.equalTo(-28)
        }
        dateLabel.snp.remakeConstraints { make in
            make.left.equalTo(bodyLabel)
            make.top.equalTo(bodyLabel.snp.bottom).offset(12)
        }
        separatorLine.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(dateLabel.snp.bottom).offset(12)
            make.height.equalTo(10)
        }
        
        backgroundPanel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview()
            make.bottom.equalTo(separatorLine.snp.top)
        }
    }

    override func bindViewModel(model: MessageTableViewCellViewModel) {
        super.bindViewModel(model: model)

        Observable.combineLatest(model.title, model.body, model.url).subscribe { title, body, url in
            
            let text = NSMutableAttributedString(
                string: body,
                attributes: [.font: RobotoFont.regular(with: 14), .foregroundColor: BKColor.grey.darken4]
            )
            
            if title.count > 0 {
                // 插入一行空行当 spacer
                text.insert(NSAttributedString(
                    string: "\n",
                    attributes: [.font: RobotoFont.medium(with: 6)]
                ), at: 0)
                
                text.insert(NSAttributedString(
                    string: title + "\n",
                    attributes: [.font: RobotoFont.medium(with: 16), .foregroundColor: BKColor.grey.darken4]
                ), at: 0)
            }
            
            if url.count > 0 {
                // 插入一行空行当 spacer
                text.append(NSAttributedString(
                    string: "\n ",
                    attributes: [.font: RobotoFont.medium(with: 8)]
                ))
                
                text.append(NSAttributedString(string: "\n\(url)", attributes: [
                    .font: RobotoFont.regular(with: 14),
                    .foregroundColor: BKColor.grey.darken4,
                    .link: url
                ]))
            }
            
            self.bodyLabel.attributedText = text
        }.disposed(by: rx.disposeBag)
        model.date.bind(to: self.dateLabel.rx.text).disposed(by: rx.reuseBag)
    }
}
