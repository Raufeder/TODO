//
//  ContentView.swift
//  Todo
//
//  Created by Derek Raufeisen on 3/4/22.
//

import SwiftUI
import Amplify
import Combine

struct ContentView: View {
    
    @State var todoSubscription: AnyCancellable?
    
    var body: some View {
        Text("We got some success messages")
        // THE ONAPPEAR RE RUNS EVEFRY TIME DATA IS CHANGED
            .onAppear {
                          self.performOnAppear()
                  }
        Button(action: getData) {
            Text("Get Data")
        }
        Button(action: addData) {
            Text("Add Data")
        }
        Button(action: mutateData) {
            Text("Change certain Data")
        }
        Button(action: deleteData) {
            Text("Delete an Instance of Data")
        }
    }
    
    func performOnAppear() {
       subscribeTodos()
    }
    
    //ADD DATA RE RUNS THE ON APPEAR FUNCTION THAT SHOWS THE DATA SUCCESSFULLY RUNNING
    func addData() {
        let item = Todo(name: "I got it",
                        description: "I think I'm getting Amplify")
            
                Amplify.DataStore.save(item) { result in
                   switch(result) {
                   case .success(let savedItem):
                       print("Saved item: \(savedItem.name)")
                   case .failure(let error):
                       print("Could not save item to DataStore: \(error)")
                   }
                }
            }
    
    //GET DATA RE RUNS THE ON APPEAR FUNCTION THAT SHOWS THE DATA SUCCESSFULLY RUNNING
    func getData() {
        Amplify.DataStore.query(Todo.self) { result in
                switch(result) {
                case .success(let todos):
                    for todo in todos {
                        print("Name: \(todo.name)")
                    }
                case .failure(let error):
                    print("Could not query DataStore: \(error)")
                }
            }
    }
    
    //CHANGE THE WHERE TO MAKE IT PART OF YOUR DATA ARRAY
    //MUTATE DATA RE RUNS THE ON APPEAR FUNCTION THAT SHOWS THE DATA SUCCESSFULLY RUNNING
    func mutateData() {
        Amplify.DataStore.query(Todo.self,
                                where: Todo.keys.name.eq("See Friends")) { result in
            switch(result) {
            case .success(let todos):
                guard todos.count == 1, var updatedTodo = todos.first else {
                    print("Did not find exactly one todo, bailing")
                    return
                }
                updatedTodo.name = "I don't have friends"
                Amplify.DataStore.save(updatedTodo) { result in
                    switch(result) {
                    case .success(let savedTodo):
                        print("Updated item: \(savedTodo.name)")
                    case .failure(let error):
                        print("Could not update data in DataStore: \(error)")
                    }
                }
            case .failure(let error):
                print("Could not query DataStore: \(error)")
            }
        }
    }

    //CHANGE THE WHERE TO MAKE IT PART OF YOUR DATA ARRAY
    //DELETE DATA RE RUNS THE ON APPEAR FUNCTION THAT SHOWS THE DATA SUCCESSFULLY RUNNING
    func deleteData() {
        Amplify.DataStore.query(Todo.self,
                                where: Todo.keys.name.eq("I got it")) { result in
            switch(result) {
            case .success(let todos):
                guard todos.count == 1, let toDeleteTodo = todos.first else {
                    print("Did not find exactly one todo, bailing")
                    return
                }
                Amplify.DataStore.delete(toDeleteTodo) { result in
                    switch(result) {
                    case .success:
                        print("Deleted item: \(toDeleteTodo.name)")
                    case .failure(let error):
                        print("Could not update data in DataStore: \(error)")
                    }
                }
            case .failure(let error):
                print("Could not query DataStore: \(error)")
            }
        }
    }

    
    func subscribeTodos() {
        self.todoSubscription
            = Amplify.DataStore.publisher(for: Todo.self)
                .sink(receiveCompletion: { completion in
                    print("Subscription has been completed: \(completion)")
                }, receiveValue: { mutationEvent in
                    print("Subscription got this value: \(mutationEvent)")

                    do {
                      let todo = try mutationEvent.decodeModel(as: Todo.self)

                      switch mutationEvent.mutationType {
                      case "create":
                        print("Created: \(todo)")
                      case "update":
                        print("Updated: \(todo)")
                      case "delete":
                        print("Deleted: \(todo)")
                      default:
                        break
                      }

                    } catch {
                      print("Model could not be decoded: \(error)")
                    }
                })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
