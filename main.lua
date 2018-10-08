-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here

math.randomseed( os.time())
-------------------
-- Variáveis
-------------------

local navio = {  }
local tabuleiro = { }
local jogador = { }



------------------- 
-- Objetos
-------------------

-- Classe navio
--dano = 0, posicao = {}, tamanho = 0
-- construtor para a criação de um novo objeto
function navio:new()
	local obj = {}
	setmetatable( obj, self)
	self.__index = self
	obj.dano = 0
	obj.posicao = {}
	obj.tamanho = 0
	return obj
end



-- Classe tabuleiro
-- navios = {}, graficoX = {}, graficoY = {}, retangulos = {}
-- construtor
function tabuleiro:new ()
      obj = {}
      setmetatable(obj, self)
      self.__index = self
      obj.navios = {}
      obj.graficoX = {}
      obj.graficoY = {}
      obj.retangulos = {}
      return obj
end

-- Classe jogador
-- pontuacao = 0, tabuleiro = tabuleiro:new(), ia = false
-- construtor
function jogador:new()
	local obj = {}
	setmetatable( obj, self)
	self.__index = self
	obj.pontuacao = 0
	obj.tabuleiro = tabuleiro:new()
	obj.ia = false
	return obj
end



--------------------
-- Métodos
--------------------

-- desenha na tela o tabuleiro
function tabuleiro:desenharGrafico( )
	
	for i = 1, 9 do
		self.graficoX[i] = display.newLine( 0, display.contentHeight * i *.10, 
		display.contentWidth, display.contentHeight * i * .10 ) 

		self.graficoY[i] = display.newLine( display.contentWidth * i * .10, 0, 
		 display.contentWidth * i * .10, display.contentHeight) 
	end

end

-- desenha retângulos na tela para serem usados pelos listeners
function tabuleiro:desenharRetangulos( )
	local paint = { 0, .15, .60}

	for i=1,10 do
		
		self.retangulos[i] = {}
		for j=1, 10 do
			self.retangulos[i][j] = display.newRect( ( display.contentWidth / 20 * ( i + i - 1) ) , (  display.contentHeight / 20 * ( j + j - 1) ) , 
				display.contentWidth / 10, display.contentHeight / 10 )
			self.retangulos[i][j].fill = paint
			self.retangulos[i][j].alpha = .5
			self.retangulos[i][j].linha = i
			self.retangulos[i][j].coluna = j
			self.retangulos[i][j].ativo = true
			--retangulos[i][j]:addEventListener ( "tap", tapListener )
		end

	end

end


--------------------
-- Funções
--------------------


local t = tabuleiro:new()
t:desenharGrafico()
t:desenharRetangulos()