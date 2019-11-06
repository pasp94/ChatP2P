//
//  MessagesCell.swift
//  ChatAspect
//
//  Created by Pasquale Spisto on 28/04/2018.
//  Copyright © 2018 pasp_development. All rights reserved.
//

import UIKit


class MessagesCell: UICollectionViewCell {
   
   public var bubbleView: UIView = {
      let view = UIView()
      view.backgroundColor = UIColor(white: 0.90, alpha: 1)
      view.layer.cornerRadius = 16
      view.layer.masksToBounds = true
      
      return view
   }()
   
   public var nameLabel: UILabel = {
      let label = UILabel()
      label.textColor = .purple
      label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
      return label
   }()
   
   public var textView: UITextView = {
      let textView = UITextView()
      textView.isUserInteractionEnabled = false
      textView.isSelectable = true
      textView.font = UIFont.systemFont(ofSize: 16)
      textView.backgroundColor = .clear
      textView.text = "Sample..."
      return textView
   }()
   
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      addSubview(bubbleView)
      addSubview(nameLabel)
      addSubview(textView)
   }
}
