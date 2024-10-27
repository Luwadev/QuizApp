import Buffer "mo:base/Buffer";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Float "mo:base/Float";

actor {
  type Question = {
    id: Nat;
    text: Text;
    options: Buffer.Buffer<Text>;
    correctAnswer: Nat; // Index of correct option
    category: Text;
  };

  type Quiz = {
    id: Nat;
    title: Text;
    category: Text;
    questions: Buffer.Buffer<Question>;
  };

  var quizzes = Buffer.Buffer<Quiz>(0);

  public func createQuiz(title: Text, category: Text) : async Nat {
    let id = quizzes.size();
    let newQuiz: Quiz = {
      id;
      title;
      category;
      questions = Buffer.Buffer<Question>(0);
    };
    quizzes.add(newQuiz);
    id
  };

  public func addQuestion(quizId: Nat, questionText: Text, options: [Text], 
    correctAnswer: Nat, category: Text) : async ?Nat {
    if (quizId >= quizzes.size()) return null;
    let quiz = quizzes.get(quizId);
    let questionId = quiz.questions.size();
    
    let optionsBuffer = Buffer.Buffer<Text>(0);
    for (option in options.vals()) {
      optionsBuffer.add(option);
    };

    let newQuestion: Question = {
      id = questionId;
      text = questionText;
      options = optionsBuffer;
      correctAnswer;
      category;
    };
    quiz.questions.add(newQuestion);
    ?questionId
  };

  public query func getQuiz(id: Nat) : async ?{
    title: Text;
    category: Text;
    questions: [{
      id: Nat;
      text: Text;
      options: [Text];
      category: Text;
    }];
  } {
    if (id >= quizzes.size()) return null;
    let quiz = quizzes.get(id);
    let questions = Buffer.Buffer<{
      id: Nat;
      text: Text;
      options: [Text];
      category: Text;
    }>(0);

    for (question in quiz.questions.vals()) {
      questions.add({
        id = question.id;
        text = question.text;
        options = Buffer.toArray(question.options);
        category = question.category;
      });
    };

    ?{
      title = quiz.title;
      category = quiz.category;
      questions = Buffer.toArray(questions);
    }
  };

  public func submitQuiz(quizId: Nat, answers: [(Nat, Nat)]) : async ?{
    totalQuestions: Nat;
    correctAnswers: Nat;
    percentage: Float;
  } {
    if (quizId >= quizzes.size()) return null;
    let quiz = quizzes.get(quizId);
    var correct = 0;
    
    for ((questionId, answer) in answers.vals()) {
      if (questionId < quiz.questions.size()) {
        let question = quiz.questions.get(questionId);
        if (question.correctAnswer == answer) {
          correct += 1;
        };
      };
    };

    let total = quiz.questions.size();
    ?{
      totalQuestions = total;
      correctAnswers = correct;
      percentage = Float.fromInt(correct) / Float.fromInt(total) * 100.0;
    }
  };
}