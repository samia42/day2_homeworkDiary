import Time "mo:base/Time";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
import Text "mo:base/Text";
actor HomeworkDiary {

  type Homework = {
    title : Text;
    description : Text;
    dueDate : Time.Time;
    completed : Bool;
  };

  let homeworkDiary = Buffer.Buffer<Homework>(0);

  // add a homework task to the diary
  public func addHomework(homework : Homework) : async Nat {
    let index = homeworkDiary.size();
    homeworkDiary.add(homework);
    return index;
  };

  // get a homework task from the diary
  public func getHomework(homeworkId : Nat) : async Result.Result<Homework, Text> {
    var gethw = homeworkDiary.getOpt(homeworkId);
    switch (gethw) {
      case null #err "not found";
      case (?gethw) #ok gethw;
    };
  };

  // update a homework task in the diary
  public func updateHomework(homeworkId : Nat, homework : Homework) : async Result.Result<(), Text> {
    var gethw = homeworkDiary.getOpt(homeworkId);
    switch (gethw) {
      case null #err "invalid id found";
      case (?gethw) {
        var updatedHW = homeworkDiary.put(homeworkId, homework);
        return #ok();
      };
    };
  };

  // delete a homework task from the diary
  public func deleteHomework(homeworkId : Nat) : async Result.Result<(), Text> {
    switch (homeworkDiary.remove(homeworkId)) {
      case (_) return #ok();
    };
    return #err("Invalid homework ID");
  };

  // get all homework
  public query func getAllHomework() : async [Homework] {
    return Buffer.toArray<Homework>(homeworkDiary);
  };

  // mark a homework task as completed
  public func markAsCompleted(homeworkId : Nat) : async Result.Result<(), Text> {
    switch (homeworkDiary.getOpt(homeworkId)) {
      case null return #err("Invalid homework ID");
      case (?result) {
        let homeworkComplete : Homework = {
          title = result.title;
          description = result.description;
          dueDate = result.dueDate;
          completed = true;
        };
        homeworkDiary.put(homeworkId, homeworkComplete);
        return #ok();
      };
    };
  };

  // get all uncompleted homework tasks in the diary
  public query func getPendingHomework() : async [Homework] {
    let pendingHW = Array.filter<Homework>(
      Buffer.toArray(homeworkDiary),
      func x = Bool.lognot(x.completed),
    );
    return pendingHW;
  };

  // search for homework tasks in the diary
  public query func searchHomework(searchTerm : Text) : async [Homework] {
    let foundHW = Array.filter<Homework>(
      Buffer.toArray(homeworkDiary),
      func x = Bool.logor(
        Text.contains(x.title, #text searchTerm),
        Text.contains(x.description, #text searchTerm),
      ),
    );
    return foundHW;
  };
};
