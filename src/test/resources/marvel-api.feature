Feature: Test de API de Personajes Marvel
  Background:
    * configure ssl = true
    * def baseUrl = 'http://bp-se-test-cabcd9b246a5.herokuapp.com'
    * def username = 'testuser'
    * def apiPath = '/api/characters'
    * def fullPath = baseUrl + '/' + username + apiPath
    * def validCharacter = read('classpath:data/characters/valid-character.json')
    * def updatedCharacter = read('classpath:data/characters/updated-character.json')
    * def invalidCharacter = read('classpath:data/characters/invalid-character.json')
    * header Content-Type = 'application/json'

  # 1. Obtener todos los personajes
  Scenario: Obtener todos los personajes
    Given url fullPath
    When method get
    Then status 200
    # La respuesta puede ser una lista vacía [] o contener elementos
  # 2. Crear un personaje (exitoso)
  Scenario: Crear un personaje exitosamente
    # Generamos un número aleatorio para hacer único el personaje
    * def random = function(){ return Math.floor((100) * Math.random()) + 1 }
    * def randomNum = random()
    * def uniqueCharacter = validCharacter
    * uniqueCharacter.name = uniqueCharacter.name + ' ' + randomNum
    * uniqueCharacter.alterego = uniqueCharacter.alterego + ' ' + randomNum
    
    Given url fullPath
    And request uniqueCharacter
    When method post
    Then status 201
    And match response contains { id: '#notnull' }
    And match response.name contains 'Black panter'
    * def characterId = response.id
  # 3. Obtener personaje por ID (exitoso)
  Scenario: Obtener un personaje por ID exitosamente
    # Generamos un número aleatorio para hacer único el personaje
    * def random = function(){ return Math.floor((100) * Math.random()) + 1 }
    * def randomNum = random()
    * def uniqueCharacter = validCharacter
    * uniqueCharacter.name = uniqueCharacter.name + ' ' + randomNum
    * uniqueCharacter.alterego = uniqueCharacter.alterego + ' ' + randomNum
    
    # Primero creamos un personaje para luego obtenerlo
    Given url fullPath
    And request uniqueCharacter
    When method post
    Then status 201
    * def characterId = response.id
    * def createdName = response.name
    * def createdAlterego = response.alterego
    
    # Ahora obtenemos el personaje creado
    Given url fullPath + '/' + characterId
    When method get
    Then status 200
    And match response.id == characterId
    And match response.name == createdName
    And match response.alterego == createdAlterego
    And match response.description == 'Genius billionaire'
    And match response.powers == ['Armor', 'Flight']
  # 4. Crear personaje (nombre duplicado)
  Scenario: Intentar crear un personaje con nombre duplicado
    # Generamos un personaje con nombre único
    * def random = function(){ return Math.floor((100) * Math.random()) + 1 }
    * def randomNum = random()
    * def uniqueCharacter = validCharacter
    * uniqueCharacter.name = uniqueCharacter.name + ' ' + randomNum
    * uniqueCharacter.alterego = uniqueCharacter.alterego + ' ' + randomNum
    
    # Primero creamos un personaje
    Given url fullPath
    And request uniqueCharacter
    When method post
    Then status 201
    
    # Creamos una copia exacta del mismo personaje (mismo nombre)
    * def duplicateCharacter = uniqueCharacter

    # Intentamos crear otro con el mismo nombre
    Given url fullPath
    And request duplicateCharacter
    When method post
    Then status 400
    And match response == { error: 'Character name already exists' }

  # 5. Crear personaje (faltan campos requeridos)
  Scenario: Intentar crear un personaje con campos requeridos faltantes
    Given url fullPath
    And request invalidCharacter
    When method post
    Then status 400
    And match response contains { name: 'Name is required' }
    And match response contains { alterego: 'Alterego is required' }
    And match response contains { description: 'Description is required' }
    And match response contains { powers: 'Powers are required' }
  # 6. Actualizar personaje (exitoso)
  Scenario: Actualizar un personaje exitosamente
    # Generamos un personaje con nombre único
    * def random = function(){ return Math.floor((100) * Math.random()) + 1 }
    * def randomNum = random()
    * def uniqueCharacter = validCharacter
    * uniqueCharacter.name = uniqueCharacter.name + ' ' + randomNum
    * uniqueCharacter.alterego = uniqueCharacter.alterego + ' ' + randomNum
    
    # Primero creamos un personaje
    Given url fullPath
    And request uniqueCharacter
    When method post
    Then status 201
    * def characterId = response.id
    
    # Preparamos los datos actualizados
    * def random2 = function(){ return Math.floor((100) * Math.random()) + 1 }
    * def randomNum2 = random2()
    * def myUpdatedCharacter = updatedCharacter
    * myUpdatedCharacter.name = myUpdatedCharacter.name + ' ' + randomNum2
    * myUpdatedCharacter.alterego = myUpdatedCharacter.alterego + ' ' + randomNum2

    # Ahora actualizamos el personaje creado
    Given url fullPath + '/' + characterId
    And request myUpdatedCharacter
    When method put
    Then status 200
    And match response.id == characterId
    And match response.name == myUpdatedCharacter.name
    And match response.alterego == myUpdatedCharacter.alterego
    And match response.description == 'Updated description'
    And match response.powers == ['Armor', 'Flight']

  # 7. Actualizar personaje (no existe)
  Scenario: Intentar actualizar un personaje que no existe
    Given url fullPath + '/999'
    And request updatedCharacter
    When method put
    Then status 404
    And match response == { error: 'Character not found' }

  # 8. Obtener personaje por ID (no existe)
  Scenario: Intentar obtener un personaje que no existe
    Given url fullPath + '/999'
    When method get
    Then status 404
    And match response == { error: 'Character not found' }
  # 9. Eliminar personaje (exitoso)
  Scenario: Eliminar un personaje exitosamente
    # Generamos un personaje con nombre único
    * def random = function(){ return Math.floor((100) * Math.random()) + 1 }
    * def randomNum = random()
    * def uniqueCharacter = validCharacter
    * uniqueCharacter.name = uniqueCharacter.name + ' ' + randomNum
    * uniqueCharacter.alterego = uniqueCharacter.alterego + ' ' + randomNum
    
    # Primero creamos un personaje
    Given url fullPath
    And request uniqueCharacter
    When method post
    Then status 201
    * def characterId = response.id

    # Ahora eliminamos el personaje creado
    Given url fullPath + '/' + characterId
    When method delete
    Then status 204

  # 10. Eliminar personaje (no existe)
  Scenario: Intentar eliminar un personaje que no existe
    Given url fullPath + '/999'
    When method delete
    Then status 404
    And match response == { error: 'Character not found' }
