import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/model/quiz.dart';
import '../../model/category.dart';
import '../../theme/theme.dart';
import 'add_categories_screens.dart';

class ManageQuizzesScreen extends StatefulWidget {
  final String? categoryId;

  const ManageQuizzesScreen({super.key, this.categoryId});

  @override
  State<ManageQuizzesScreen> createState() => _ManageQuizzesScreenState();
}

class _ManageQuizzesScreenState extends State<ManageQuizzesScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String? _selectedCategoryId;
  String? selectedCategoryId;
  List<Category> _categories = <Category>[];
  Category? _initialCategory;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    try {
      final querySnapshot = await _firestore.collection('categories').get();
      final loadedCategories = querySnapshot.docs
          .map((doc) => Category.fromMap(doc.id, doc.data()))
          .toList();
      setState(() {
        _categories = loadedCategories;
        if (widget.categoryId != null) {
          _initialCategory = _categories.firstWhere(
            (category) => category.id == widget.categoryId,
            orElse: () => Category(id: '', name: "Unknown", description: ''),
          );
          _selectedCategoryId = _initialCategory!.id;
          selectedCategoryId = _selectedCategoryId;
        }
      });
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Stream<QuerySnapshot> _getQuizStream() {
    Query query = _firestore.collection('quizzes');
    String? filterCategoryId = _selectedCategoryId ?? widget.categoryId;

    if (filterCategoryId != null) {
      query = query.where('categoryId', isEqualTo: filterCategoryId);
    }

    if (_searchQuery.isNotEmpty) {
      query = query.where('name', isGreaterThanOrEqualTo: _searchQuery);
    }

    return query.snapshots();
  }

  Widget _bulidTitle() {
    String? categoyId = _selectedCategoryId ?? widget.categoryId;
    if (categoyId == null) {
      return Text("All Quizzes", style: TextStyle(fontWeight: FontWeight.bold));
    }
    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection("categories").doc(categoyId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text(
            "Loading...",
            style: TextStyle(fontWeight: FontWeight.bold),
          );
        }

        final category = Category.fromMap(
          categoyId,
          snapshot.data!.data() as Map<String, dynamic>,
        );
        
        return Text(
          category.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        title: _bulidTitle(),
      actions: [
        IconButton(
          icon: Icon(Icons.add_circle_outline,color: AppTheme.primaryColor,),
            onPressed: (){
              Navigator.push(
                context, MaterialPageRoute(
                builder:(context) => AddCategoriesScreens(),
              ),
              );
           }
           ),
      ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                hintText: "Search Quizzes",
               prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),

              ),
              onChanged: (value){
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 10 ,horizontal: 18),
              border: OutlineInputBorder(

              ),
              hintText:"Category" ,
              ),
              value: _selectedCategoryId,
                  items:[
                    DropdownMenuItem(
                  child: Text("All Categories"),
                  value: null,
                    ),
                    if(_initialCategory != null &&
                    _categories.every((c)=> c.id != _initialCategory!.id))
                      DropdownMenuItem(
                        child: Text(_initialCategory!.name),
                        value: _initialCategory!.id,
                      ),
                      ..._categories.map((category)=> DropdownMenuItem(
                        child: Text(category.name),
                        value: category.id,
                      ),
                    ),
                  ] ,
              onChanged: (value){
                setState(() {
                  _selectedCategoryId = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getQuizStream(),
              builder: (context, snapshot){
                if(!snapshot.hasError){
               return Center(
               child: Text("An Error Occurred"),);}
                if(snapshot.hasData){
                return Center(
                child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                ),
                );
                }
                final quizzes = snapshot.data!.docs
                    .map((doc) => Quiz.fromMap(doc.id as Map<String, dynamic> ,doc.data() as Map<String, dynamic>, )).
                    where((quiz) => _searchController.text.isEmpty || quiz.title.toLowerCase().contains(_searchQuery))
                    .toList();
                 if(quizzes.isEmpty){
                  return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.quiz_outlined, color: AppTheme.textSecondaryColor, size: 64),
                      SizedBox(height: 16),
                      Text(
                        "No quizzes yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondaryColor,
                        ),
                      ),
                      SizedBox(height: 8,),
                      ElevatedButton(
                        onPressed: (){
                          //Navigate.push(context, MaterialPageRoute(builder: builder )=> AddQuizScreen(categoryId: widget.categoryId),);
                          },
                        child: Text("Add Quiz"),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                itemCount: quizzes.length,
                itemBuilder: (context,index){
                  final Quiz quiz = quizzes[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      leading: Container(
                        padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            ),
                        child: Icon(Icons.quiz_rounded,
                            color: AppTheme.primaryColor
                        ),
                      ),
                      title: Text(quiz.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                         ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8,),
                          Row(
                            children: [
                              Icon(Icons.question_answer_outlined,
                                size: 16,
                                color: AppTheme.textSecondaryColor,
                              ),
                              SizedBox(width: 4,
                              ),
                              Text("${quiz.questions.length} Questions"),
                              SizedBox(width: 16),
                              Icon(Icons.timer,
                              size: 16,
                              ),
                              SizedBox(width: 4,
                              ),
                              Text("${quiz.timeLimit} Min"),
                            ],
                          ),
                        ],
                      ),
                      trailing:PopupMenuButton(itemBuilder: (context)=>[
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined,
                            color: AppTheme.primaryColor,),
                            title: Text("Edit"),
                          ),
                        ),
                      PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_outlined,
                            color: Colors.redAccent,),
                           title: Text("Edit"),
                             ),
                           ),
                          ],
                          onSelected: (value )=>
                        _handleMenuSelection(context,value, quiz),
                        )
                    ),
                  );
                }
                );
                 },
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _handleMenuSelection(
    BuildContext context,
    String action,
    Quiz quiz,
  ) async {
    if (action == 'edit') {
      //  Navigator.push(context, MaterialPageRoute(builder: (context) => AddQuizScreen(quiz: quiz,),),);
    } else if (action == 'delete') {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Delete Quiz"),
          content: Text("Are you sure you want to delete this quiz?"),
          actions: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () { Navigator.pop(context, false);
                },
            ),
            TextButton(
              child: Text("Delete", style: TextStyle(color: Colors.redAccent)),
              onPressed: () { Navigator.pop(context, true);
                },
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _firestore.collection('quizzes').doc(quiz.id).delete();
      }
    }
  }
}
