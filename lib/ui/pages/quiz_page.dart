import 'package:flutter/material.dart';
import 'package:flutter_jpn_ocr/models/category.dart';
import 'package:flutter_jpn_ocr/models/question.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:flutter_jpn_ocr/ui/pages/quiz_finished.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:flutter_jpn_ocr/recognizer/contants.dart';
import 'package:flutter_jpn_ocr/recognizer/drawing_painter.dart';
import 'package:flutter_jpn_ocr/recognizer/brain.dart';

class QuizPage extends StatefulWidget {
  final List<Question> questions;
  final Category category;

  const QuizPage({Key key, @required this.questions, this.category}) : super(key: key);

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Offset> points = List();
  AppBrain brain = AppBrain();
  
String headerText = 'Header placeholder';
  String footerText = 'Footer placeholder';
  double accuracy = 0.58;

  

  void _resetLabels() {
    headerText = kWaitingForInputHeaderString;
    footerText = kWaitingForInputFooterString;
    accuracy = 0.00;
  }

  void _setLabelsForGuess(String guess,double acc) {
    headerText = ""; // Empty string
    accuracy = acc*100;
    footerText = kGuessingInputString + guess + "-" + accuracy.toInt().toString() + "%";
  }
  
  

  void _cleanDrawing() {
    setState(() {
      points = List();
    });
  }
  
  final TextStyle _questionStyle = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w500,
    color: Colors.white
  );

  int _currentIndex = 0;
  final Map<int,dynamic> _answers = {};
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    brain.loadModel();
    _resetLabels();
  }

  @override
  Widget build(BuildContext context){
    //print(widget);
    Question question = widget.questions[_currentIndex];
    //print(question);
    final List<dynamic> options = question.incorrectAnswers;
    
    if(!options.contains(question.correctAnswer)) {
      options.add(question.correctAnswer);
      options.shuffle();
    }
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: _key,
        appBar: AppBar(
          title: Text(widget.category.name),
          elevation: 0,
        ),
        body: Stack(
          children: <Widget>[
            ClipPath(
              clipper: WaveClipperTwo(),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor
                ),
                height: 200,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.white70,
                        child: Text("${_currentIndex+1}"),
                      ),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Text(HtmlUnescape().convert(widget.questions[_currentIndex].question),
                          softWrap: true,
                          style: _questionStyle,),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.0),
                  Card(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ...options.map((option)=>RadioListTile(
                          title: Text(HtmlUnescape().convert("$option")),
                          groupValue: _answers[_currentIndex],
                          value: option,
                          onChanged: (value){
                            setState(() {
                              _answers[_currentIndex] = option;
                            });
                          },
                        )),
                      ],
                    ),
                  ),

                  Container(
              decoration: new BoxDecoration(
                border: new Border.all(
                  width: 3.0,
                  color: Colors.blue,
                ),
              ),
              child: Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(
                            renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanStart: (details) {
                      setState(() {
                        RenderBox renderBox = context.findRenderObject();
                        points.add(
                            renderBox.globalToLocal(details.globalPosition));
                      });
                    },
                    onPanEnd: (details) async {
                      points.add(null);
                      List predictions = await brain.processCanvasPoints(points);
                      print(predictions);
                      setState(() {
                        _setLabelsForGuess(predictions.first['label'], predictions.first['confidence']);
                      });
                    },
                    child: ClipRect(
                      child: CustomPaint(
                        size: Size(kCanvasSize, kCanvasSize),
                        painter: DrawingPainter(
                          offsetPoints: points,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      child: RaisedButton(
                        child: Text( _currentIndex == (widget.questions.length - 1) ? "Nộp" : "Tiếp theo"),
                        onPressed: _nextSubmit,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
        onPressed: () {
          _cleanDrawing();
          _resetLabels();
        },
        tooltip: 'Clean',
        child: Icon(Icons.delete),
      ),
      ),
    );
  }

  void _nextSubmit() {
    if(points.isEmpty == true) {
      _key.currentState.showSnackBar(SnackBar(
        content: Text("You must write an answer to continue."),
      ));
      return;
    } else {
      _key.currentState.showSnackBar(SnackBar(
        content: Text(footerText),
      ));
    }
    if(_currentIndex < (widget.questions.length - 1)){
      setState(() {
          _currentIndex++;
      });
      _cleanDrawing();
      _resetLabels();
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => QuizFinishedPage(questions: widget.questions, answers: _answers)
      ));
    }
  }

  Future<bool> _onWillPop() async {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          content: Text("Bạn có chắc muốn thoát? Toàn bộ quá trình sẽ bị mất dữ liệu."),
          title: Text("Cảnh báo!"),
          actions: <Widget>[
            FlatButton(
              child: Text("Có"),
              onPressed: (){
                Navigator.pop(context,true);
              },
            ),
            FlatButton(
              child: Text("Không"),
              onPressed: (){
                Navigator.pop(context,false);
              },
            ),
          ],
        );
      }
    );
  }
}