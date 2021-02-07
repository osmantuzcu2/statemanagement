import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statemanagement/bloc/cat.dart';
import 'package:statemanagement/bloc/cats_cubit.dart';
import 'package:statemanagement/bloc/cats_repository.dart';
import 'package:statemanagement/bloc/cats_state.dart';

class BlocCatsView extends StatefulWidget {
  @override
  _BlocCatsViewState createState() => _BlocCatsViewState();
}

class _BlocCatsViewState extends State<BlocCatsView> {
  BuildContext _context;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _context.bloc<CatsCubit>().getCats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (c) {
        return CatsCubit(SampleCatsRepository());
      },
      child: buildScaffold(context),
    );
  }

  Scaffold buildScaffold(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text("Hello"),
        ),
        body: BlocConsumer<CatsCubit, CatsState>(
          listener: (c, state) {
            if (state is CatsError) {
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (c, state) {
            _context = c;
            if (state is CatsInitial) {
              return buildCenterInitialChild(context);
            } else if (state is CatsLoading) {
              return buildCenterLoading();
            } else if (state is CatsCompleted) {
              return buildListViewCats(state, _context);
            } else {
              return buildError(state);
            }
          },
        ),
      );

  Text buildError(CatsState state) {
    final error = state as CatsError;
    return Text(error.message);
  }

  Stack buildListViewCats(CatsCompleted state, BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          itemBuilder: (context, index) => ListTile(
            title: Image.network(state.response[index].imageUrl),
            subtitle: Text(state.response[index].description),
          ),
          itemCount: state.response.length,
        ),
        Row(
          children: [
            FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () {
                context.bloc<CatsCubit>().addCat(Cat(
                    statusCode: 100,
                    description: "test",
                    imageUrl: "https://http.cat/100"));
              },
            ),
            FloatingActionButton(
              child: Icon(Icons.clear),
              onPressed: () {
                context.bloc<CatsCubit>().clearAll();
              },
            ),
          ],
        )
      ],
    );
  }

  Center buildCenterLoading() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Center buildCenterInitialChild(BuildContext context) {
    return Center(
      child: Column(
        children: [Text("Hello"), buildFloatingActionButtonCall(context)],
      ),
    );
  }

  FloatingActionButton buildFloatingActionButtonCall(BuildContext context) {
    return FloatingActionButton(
      child: Icon(Icons.clear_all),
      onPressed: () {
        context.bloc<CatsCubit>().getCats();
      },
    );
  }
}
