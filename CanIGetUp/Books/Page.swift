//  Created by dasdom on 01.01.21.
//  Copyright © 2021 dasdom. All rights reserved.
//

import Foundation

struct Page: Codable, Equatable {
  let id: UUID
  
  init() {
    id = UUID()
  }
}
