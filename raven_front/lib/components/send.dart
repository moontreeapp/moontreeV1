import 'package:flutter/material.dart';

PreferredSize header(context) {
  return PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          backgroundColor: Colors.blue[900],
          elevation: 2,
          centerTitle: false,
          leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey[100]),
              onPressed: () => Navigator.pop(context)),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                    onTap: () {}, child: Icon(Icons.more_horiz)))
          ],
          title: Text('Wallet',
              style: TextStyle(fontSize: 18.0, letterSpacing: 2.0)),
          flexibleSpace: Container(
            color: Colors.blue[900],
            alignment: Alignment.center,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('\n0 RVN',
                    style: TextStyle(
                        fontSize: 24.0,
                        letterSpacing: 2.0,
                        color: Colors.white)),
                IconButton(
                    onPressed: () {
                      /*show available assets and balances for this account*/
                    },
                    padding: EdgeInsets.only(top: 24.0),
                    icon: Icon(
                      Icons.change_circle_outlined,
                      color: Colors.white,
                    ))
              ]),
              Text('\n\$ 0.00',
                  style: TextStyle(
                      fontSize: 16.0, letterSpacing: 2.0, color: Colors.white))
            ]),
          )));
}

ListView body(_formKey) {
  var _controller = TextEditingController();
  return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.all(20.0),
      children: <Widget>[
        Form(
            key: _formKey,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'To',
                        hintText: 'Address'),
                    //validator: (String? value) {
                    //  //if (value == null || value.isEmpty) {
                    //  //  return 'Please enter a valid address';
                    //  //}
                    //  //return null;
                    //},
                  ),
                  TextButton.icon(
                      onPressed: () {
                        /* qr code scanner get value put in textbox
                          # need a qr code scanner:
                          # https://pub.dev/packages/qr_code_scanner
                          # https://pub.dev/packages/qrscan
                        */
                      },
                      icon: Icon(Icons.qr_code_scanner),
                      label: Text('Scan QR code')),
                  TextFormField(
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Amount',
                        hintText: 'Quantity'),
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('fee'), Text('0.01397191 RVN')]),
                  TextFormField(
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                        border: UnderlineInputBorder(),
                        labelText: 'Note',
                        hintText: 'Note to Self'),
                  ),
                  //Center(child: sendTransactionButton(_formKey))
                ]))
      ]);
}

ElevatedButton sendTransactionButton(_formKey) {
  return ElevatedButton.icon(
      icon: Icon(Icons.send),
      label: Text('Send'),
      onPressed: () {
        // Validate will return true if the form is valid, or false if
        // the form is invalid.
        if (_formKey.currentState!.validate()) {
          // Process data.
        }
      },
      style: ButtonStyle(
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  bottomLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                  bottomRight: Radius.circular(30.0))))));
}
