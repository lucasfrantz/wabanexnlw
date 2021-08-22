defmodule WabanexWeb.SchemaTest do
  use WabanexWeb.ConnCase, async: true

  alias Wabanex.User
  alias Wabanex.Users.Create

  describe "users query" do
    test "when a valid id is given, returns the use", %{conn: conn} do
      params = %{email: "rafael@banana.com", name: "Rafael", password: "123456"}

      {:ok, %User{id: user_id}} = Create.call(params)

      query = """
        {
          getUser(id:"#{user_id}"){
            email
            name
          }
        }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(:ok)

      expected_response = %{
        "data" => %{
          "getUser" => %{
            "email" => "rafael@banana.com",
            "name" => "Rafael"
          }
        }
      }

      assert response == expected_response
    end

    test "when an invalid id is given, returns an error", %{conn: conn} do
      query = """
        {
          getUser(id:"123"){
            email
            name
          }
        }
      """

      response =
        conn
        |> post("/api/graphql", %{query: query})
        |> json_response(:ok)

      expected_response = %{
        "errors" => [
          %{
            "locations" => [%{"column" => 13, "line" => 2}],
            "message" => "Argument \"id\" has invalid value \"123\"."
          }
        ]
      }

      assert response == expected_response
    end
  end

  describe "users mutations" do
    test "when all params are valid, creates the user", %{conn: conn} do
      mutation = """
      mutation
      {
        createUser(input: {name:"Joao",email:"joao@bananaa.com",password:"123426"})
        {
          id
          name
        }
      }
      """

      response =
        conn
        |> post("/api/graphql", %{query: mutation})
        |> json_response(:ok)

      assert %{"data" => %{"createUser" => %{"id" => _id, "name" => "Joao"}}} = response
    end
  end
end
