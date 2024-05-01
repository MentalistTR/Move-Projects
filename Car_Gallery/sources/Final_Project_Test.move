#[test_only]

module final::Final_Project_Test {
    use sui::test_scenario;
    use final::Final_Project::Gallery;
    use final::Final_Project::Car;
    use final::Final_Project as fp;
    use sui::coin::{Self,Coin,mint_for_testing};
    use sui::sui::SUI;
    use sui::object_table;
    
    #[test]

    fun test_Final_Project() {
         let owner: address = @0xA;
         let user1: address = @0xB;
         let user2: address = @0xC;

      // const NOT_THE_OWNER: u64 = 0;
      // const INSUFFICIENT_FUNDS: u64 = 1;
      // const MIN_CAR_COST: u64 = 2;
      // const CAR_FOR_NOT_SALE: u64 = 3;
      // const INVALID_VALUE: u64 = 4;  
      
      let scenario_val = test_scenario::begin(owner);
      let scenario = &mut scenario_val;

     // Variables  for creating Car 

       let name = b"Test Car";
       let model = b"Model X";
       let img_url = b"https://hizliresim.com/q82e6jw";
       let year: u64 = 1998;
       let price: u64 = 10;
       let color = b"Grey";
       let distance: u64 = 600000;
       let payment = mint_for_testing<SUI>(100,test_scenario::ctx(scenario));
       let for_sale = true;

    test_scenario::next_tx(scenario, owner);
         {
            fp::init_for_testing(test_scenario::ctx(scenario));
            
         };

    test_scenario::next_tx(scenario,user1);
         {
            let project_val = test_scenario::take_shared<fp::Gallery>(scenario);
            let project = &mut project_val;
            
             assert!( fp::get_owner(project) == owner,0);
             assert!(fp::get_counter(project) == 0, 4);
   
            // create a car from user1
            fp::create_Car(name,model,img_url,year,price,color,distance,project,payment,test_scenario::ctx(scenario));

            // check Gallery count must be equal 1  
           assert!(fp::get_counter(project) == 1, 4);

           test_scenario::return_shared(project_val);

          };

    test_scenario::next_tx(scenario,user2);

           {
      
        let project_val = test_scenario::take_shared<fp::Gallery>(scenario);
        let project = &mut project_val;

      
        // get_car_info function should return Car object variables. 
       let (_asset_name, asset_owner, _asset_model, asset_year, _asset_img_url, _asset_color, asset_distance, asset_for_sale, asset_price) = fp::get_car_info(project,1);
      
       assert!(asset_owner == user1,0);
       assert!(asset_year ==year ,4);
       assert!(asset_distance== distance,4);
       assert!(asset_for_sale == for_sale,3);
       assert!(asset_price == price,4);
     
    test_scenario::return_shared(project_val);
           };

    test_scenario::next_tx(scenario,user2);

       {

        let project_val = test_scenario::take_shared<fp::Gallery>(scenario);
        let project = &mut project_val;
        let payment1 = mint_for_testing<SUI>(100, test_scenario::ctx(scenario));
        
        //user2 going to buy car from user1.
        fp::buy_car(project, 1, payment1, test_scenario::ctx(scenario));
    
        // Gallery counter must be decrease so it was 1 and now it must be 0
        assert!(fp::get_counter(project) == 1, 4);
        
 
        test_scenario::return_shared(project_val);

       };

       test_scenario::next_tx(scenario,user2); 
       {
           //after user2 called buy_car function we call the get_car_info so we can check new infos.
        let car_val = test_scenario::take_from_sender<fp::Car>(scenario); 
        let car = &mut car_val;

        let (_asset_name, asset_owner, _asset_model, _asset_year, _asset_img_url, _asset_color, _asset_distance, asset_for_sale, _asset_price) = fp::get_car_single(car);
       
         // owner must be change. 
          assert!(asset_owner == user2,0);
        //  after car sold asset_for_sale must be false.
          assert!(asset_for_sale == false,3);
        
        test_scenario::return_to_sender<fp::Car>(scenario,car_val);
       };

      test_scenario::next_tx(scenario,user2);

      {
      //user2 lives in Turkey and he thinks he can make profit in car trade. So he is going to change car price 
      
      let car_val = test_scenario::take_from_sender<fp::Car>(scenario); 
      let car = &mut car_val;

      let project_val = test_scenario::take_shared<fp::Gallery>(scenario);
      let project = &mut project_val;
   
      let new_year : u64 = 1998;
      let new_distance: u64 = 600100;
      let new_for_sale: bool = true;
      let new_price:u64 = 15;
      let user_address =  user2;
    
      //  user2 updated his own car
    
      fp:: update_car_property(car,new_year,new_distance,new_for_sale,new_price,user_address);
      test_scenario::return_to_sender<fp::Car>(scenario,car_val);
  
       test_scenario::return_shared(project_val);
         };

       test_scenario::next_tx(scenario,user2);

     {
      // user2 updated new prices and now he has to add this object to gallery. 
 
      let project_val = test_scenario::take_shared<fp::Gallery>(scenario);
      let project = &mut project_val;

      let new_car_val = test_scenario::take_from_sender<fp::Car>(scenario); 
     
      fp::add_car_to_gallery(project, new_car_val, test_scenario::ctx(scenario));
      assert!(fp::get_counter(project) == 2, 4);

     
       let new_year : u64 = 1998;
       let new_distance: u64 = 600100;
       let new_for_sale: bool = true;
       let new_price:u64 = 15;
       let user_address =  user2;

       // user2 check car property
       let (_asset_name, asset_owner, _asset_model, _asset_year, _asset_img_url, _asset_color, _asset_distance, asset_for_sale, _asset_price) = fp::get_car_info(project, 2);

       assert!(asset_owner == user2,0);
       assert!(asset_for_sale == true,3);
       assert!(new_distance ==_asset_distance,4);
       assert!(_asset_price == new_price,4);

       test_scenario::return_shared(project_val);

        };

      test_scenario::next_tx(scenario,user1); 

       {
       
    let project_val = test_scenario::take_shared<fp::Gallery>(scenario);
    let project = &mut project_val;
    let payment1 = mint_for_testing<SUI>(100, test_scenario::ctx(scenario));
    
     //user1 going to buy car from user1.
     fp::buy_car(project, 2, payment1, test_scenario::ctx(scenario));

     // Gallery counter must be decrease so it was 1 and now it must be 0
     assert!(fp::get_counter(project) == 2, 4);

     test_scenario::return_shared(project_val);
       
       };

  test_scenario::next_tx(scenario,user1);

       {
        // user1 decided to delete car
        let project_val = test_scenario::take_shared<fp::Gallery>(scenario);
        let project = &mut project_val;

        let new_car_val = test_scenario::take_from_sender<fp::Car>(scenario); 

        fp::delete_car(new_car_val,project,test_scenario::ctx(scenario));
        assert!(fp::get_counter(project) == 2,4);

        test_scenario::return_shared(project_val);
       };

 test_scenario::end(scenario_val);
    }

}