import 'dart:convert';

Cources courcesFromJson(String str) => Cources.fromJson(json.decode(str));

String courcesToJson(Cources data) => json.encode(data.toJson());

class Cources{
  String tokenType;
  String accessToken;
  int expiresIn;
  String refreshToken;


  Cources({
    required this.tokenType,
    required this.accessToken,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory Cources.fromJson(Map<String,dynamic> json)=>Cources(
    tokenType: json["tokenType"], 
    accessToken: json["accessToken"], 
    expiresIn: json["expiresIn"], 
    refreshToken: json["refreshToken"],
    );
    Map<String,dynamic>toJson()=>{
      "tokenType":tokenType,
      "accessToken":accessToken,
      "expiresIn":expiresIn,
      "refreshToken":refreshToken,
    };

}
 